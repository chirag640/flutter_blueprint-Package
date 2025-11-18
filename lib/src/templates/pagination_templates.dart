import '../config/blueprint_config.dart';

/// Generates pagination controller for managing paginated data
String generatePaginationController(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

/// State for pagination
enum PaginationStatus {
  initial,
  loading,
  loadingMore,
  success,
  failure,
  empty,
}

/// Pagination controller for managing paginated lists
class PaginationController<T> extends ChangeNotifier {
  PaginationController({
    required this.fetchPage,
    this.itemsPerPage = 20,
  });

  /// Function to fetch a page of data
  final Future<List<T>> Function(int page) fetchPage;

  /// Items per page
  final int itemsPerPage;

  // State
  PaginationStatus _status = PaginationStatus.initial;
  List<T> _items = [];
  int _currentPage = 1;
  bool _hasMorePages = true;
  String? _errorMessage;

  // Getters
  PaginationStatus get status => _status;
  List<T> get items => List.unmodifiable(_items);
  int get currentPage => _currentPage;
  bool get hasMorePages => _hasMorePages;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PaginationStatus.loading;
  bool get isLoadingMore => _status == PaginationStatus.loadingMore;
  bool get hasError => _status == PaginationStatus.failure;
  bool get isEmpty => _status == PaginationStatus.empty;

  /// Load first page
  Future<void> loadFirstPage() async {
    if (_status == PaginationStatus.loading) return;

    _status = PaginationStatus.loading;
    _items.clear();
    _currentPage = 1;
    _hasMorePages = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItems = await fetchPage(_currentPage);

      if (newItems.isEmpty) {
        _status = PaginationStatus.empty;
      } else {
        _items = newItems;
        _status = PaginationStatus.success;
        _hasMorePages = newItems.length >= itemsPerPage;
      }
    } catch (e) {
      _status = PaginationStatus.failure;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (!_hasMorePages || _status == PaginationStatus.loadingMore) {
      return;
    }

    _status = PaginationStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newItems = await fetchPage(nextPage);

      _items.addAll(newItems);
      _currentPage = nextPage;
      _hasMorePages = newItems.length >= itemsPerPage;
      _status = PaginationStatus.success;
    } catch (e) {
      _status = PaginationStatus.failure;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Refresh (reload first page)
  Future<void> refresh() async {
    await loadFirstPage();
  }

  /// Retry after error
  Future<void> retry() async {
    if (_items.isEmpty) {
      await loadFirstPage();
    } else {
      await loadNextPage();
    }
  }

  /// Reset controller
  void reset() {
    _status = PaginationStatus.initial;
    _items.clear();
    _currentPage = 1;
    _hasMorePages = true;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
""";
}

/// Generates paginated list view widget
String generatePaginatedListView(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

import 'pagination_controller.dart';

/// A list view with built-in pagination support
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.loadingMoreBuilder,
    this.padding,
    this.physics,
  });

  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, String? error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? loadingMoreBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load first page if not already loaded
    if (widget.controller.status == PaginationStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadFirstPage();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && widget.controller.hasMorePages) {
      widget.controller.loadNextPage();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9); // Trigger at 90%
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final status = widget.controller.status;

        // Loading state (first page)
        if (status == PaginationStatus.loading) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        // Empty state
        if (status == PaginationStatus.empty) {
          return widget.emptyBuilder?.call(context) ??
              const Center(child: Text('No items found'));
        }

        // Error state (first page)
        if (status == PaginationStatus.failure &&
            widget.controller.items.isEmpty) {
          return widget.errorBuilder
                  ?.call(context, widget.controller.errorMessage) ??
              _buildDefaultError();
        }

        // Success state
        final items = widget.controller.items;
        return RefreshIndicator(
          onRefresh: widget.controller.refresh,
          child: ListView.separated(
            controller: _scrollController,
            padding: widget.padding,
            physics: widget.physics,
            itemCount: items.length + (widget.controller.hasMorePages ? 1 : 0),
            separatorBuilder: (context, index) {
              return widget.separatorBuilder?.call(context, index) ??
                  const SizedBox.shrink();
            },
            itemBuilder: (context, index) {
              // Loading more indicator
              if (index >= items.length) {
                if (status == PaginationStatus.failure) {
                  return _buildLoadMoreError();
                }
                return widget.loadingMoreBuilder?.call(context) ??
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
              }

              // Regular item
              return widget.itemBuilder(context, items[index], index);
            },
          ),
        );
      },
    );
  }

  Widget _buildDefaultError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            widget.controller.errorMessage ?? 'Failed to load data',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.controller.retry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreError() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            'Failed to load more',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.controller.retry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
""";
}

/// Generates skeleton loader widget
String generateSkeletonLoader(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

/// Skeleton loader for list items during loading state
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Pre-built skeleton for list items
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const SkeletonLoader(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading list
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 10,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonListTile(),
    );
  }
}
""";
}
