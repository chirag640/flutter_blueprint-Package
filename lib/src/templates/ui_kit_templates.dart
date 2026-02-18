// ignore_for_file: lines_longer_than_80_chars

import '../config/blueprint_config.dart';

/// Generates the ValidationAckScope widget (companion for the dropdown).
///
/// Allows a parent Form to collect validation errors without showing inline
/// error text under each field — useful for single-error-banner patterns.
String generateValidationAckScope(BlueprintConfig config) {
  return r'''
import 'package:flutter/material.dart';

/// Accumulates validation error messages from descendant form fields.
///
/// Usage:
/// ```dart
/// final _controller = ValidationAckController();
///
/// ValidationAckScope(
///   controller: _controller,
///   hideInlineErrors: true,
///   child: Form(
///     key: _formKey,
///     child: Column(children: [...]),
///   ),
/// );
///
/// // On submit:
/// _controller.clear();
/// if (_formKey.currentState!.validate()) { ... }
/// final errors = _controller.errors; // show banner
/// ```
class ValidationAckScope extends InheritedWidget {
  const ValidationAckScope({
    super.key,
    required this.controller,
    required super.child,
    this.hideInlineErrors = false,
  });

  final ValidationAckController controller;

  /// When true, descendant fields suppress their inline error text and instead
  /// push the message into [controller].
  final bool hideInlineErrors;

  static ValidationAckScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ValidationAckScope>();

  @override
  bool updateShouldNotify(ValidationAckScope oldWidget) =>
      oldWidget.controller != controller ||
      oldWidget.hideInlineErrors != hideInlineErrors;
}

/// Controller that collects validation error strings from form fields.
class ValidationAckController extends ChangeNotifier {
  final List<String> _errors = [];

  List<String> get errors => List.unmodifiable(_errors);

  bool get hasErrors => _errors.isNotEmpty;

  void add(String error) {
    _errors.add(error);
    notifyListeners();
  }

  void clear() {
    _errors.clear();
    notifyListeners();
  }
}
''';
}

/// Generates AppTextFieldWithLabel — a text field with a floating label that
/// sits **on** the border (Material 3 outlined style, fully custom).
///
/// Supports both light and dark themes via ThemeData / ColorScheme.
String generateAppTextFieldWithLabel(BlueprintConfig config) {
  return r'''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/validation_ack_scope.dart';

/// A polished text field with a floating label that clips the border.
///
/// The label floats to the top border when the field is focused or has text.
/// Supports required-field asterisk, password toggle, error messages, and
/// adapts automatically to the app's ThemeMode (light / dark).
///
/// Example:
/// ```dart
/// AppTextFieldWithLabel(
///   controller: _emailCtrl,
///   label: 'Email Address',
///   keyboardType: TextInputType.emailAddress,
///   isRequired: true,
///   validator: Validators.email,
/// )
/// ```
class AppTextFieldWithLabel extends StatefulWidget {
  const AppTextFieldWithLabel({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.onChanged,
    this.isRequired = false,
    this.maxLength,
    this.counterText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final void Function(String)? onChanged;
  final bool isRequired;
  final int? maxLength;
  final String? counterText;
  final bool autofocus;

  @override
  State<AppTextFieldWithLabel> createState() => _AppTextFieldWithLabelState();
}

class _AppTextFieldWithLabelState extends State<AppTextFieldWithLabel> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
    widget.controller.addListener(_rebuild);
    _obscured = widget.obscureText;
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});
  void _onFocusChange() => setState(() => _isFocused = _focusNode.hasFocus);

  // ── theme-aware colours ────────────────────────────────────────────────────
  Color _borderColor(BuildContext context, {required bool hasError}) {
    if (hasError) return Theme.of(context).colorScheme.error;
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black;
  }

  Color _focusedBorderColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  Color _labelColor(BuildContext context, {required bool hasError}) =>
      hasError ? Theme.of(context).colorScheme.error : _borderColor(context, hasError: false);

  Color _textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1A1A1A);

  Color _hintColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white38
          : const Color(0xFF9E9E9E);

  Color _fillColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white;

  @override
  Widget build(BuildContext context) {
    final ackScope = ValidationAckScope.maybeOf(context);

    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.controller.text)
          : null,
      builder: (FormFieldState<String> state) {
        final hasError = state.hasError;
        final errorText = state.errorText;

        // Propagate error to ValidationAckScope if present
        if (ackScope != null && ackScope.hideInlineErrors) {
          if (hasError && errorText != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => ackScope.controller.add(errorText),
            );
          }
        }

        final showInlineError =
            hasError && !(ackScope?.hideInlineErrors ?? false);
        final activeBorderColor = _isFocused
            ? _focusedBorderColor(context)
            : _borderColor(context, hasError: hasError);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // ── field container ───────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: _fillColor(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: activeBorderColor,
                      width: 2,
                    ),
                  ),
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    readOnly: widget.readOnly,
                    onTap: widget.onTap,
                    keyboardType: widget.keyboardType,
                    maxLines: widget.obscureText ? 1 : widget.maxLines,
                    minLines: widget.maxLines == 1 ? null : 1,
                    obscureText: widget.obscureText && _obscured,
                    enabled: widget.enabled,
                    inputFormatters: widget.inputFormatters,
                    textInputAction: widget.textInputAction,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    autofillHints: widget.autofillHints,
                    maxLength: widget.maxLength,
                    onChanged: (v) {
                      state.didChange(v);
                      widget.onChanged?.call(v);
                    },
                    cursorColor: _textColor(context),
                    style: TextStyle(
                      color: _textColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      // Show hint/placeholder label only when unfocused and empty
                      label: (!_isFocused && widget.controller.text.isEmpty)
                          ? _buildLabel(
                              widget.hintText ?? widget.label,
                              context: context,
                              floating: false,
                              hasError: false,
                            )
                          : null,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintStyle: TextStyle(color: _hintColor(context)),
                      filled: true,
                      fillColor: _fillColor(context),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      // Suppress built-in error — we draw it ourselves
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                      prefixIcon: widget.prefixIcon,
                      suffixIcon: _buildSuffixIcon(context),
                      counterText: widget.counterText,
                    ),
                  ),
                ),
                // ── floating label clipped to border ──────────────────────
                if (!widget.readOnly &&
                    (_isFocused || widget.controller.text.isNotEmpty))
                  Positioned(
                    left: 12,
                    top: -9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      color: _fillColor(context),
                      child: _buildLabel(
                        widget.label,
                        context: context,
                        floating: true,
                        hasError: hasError,
                      ),
                    ),
                  ),
              ],
            ),
            // ── inline error ───────────────────────────────────────────────
            if (showInlineError && errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  errorText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(
    String text, {
    required BuildContext context,
    required bool floating,
    required bool hasError,
  }) {
    final color = _labelColor(context, hasError: hasError);
    final style = TextStyle(
      color: floating ? color : _hintColor(context),
      fontSize: floating ? 11 : 16,
      fontWeight: FontWeight.w600,
    );

    if (widget.isRequired) {
      return RichText(
        text: TextSpan(
          text: text,
          style: style,
          children: [
            TextSpan(
              text: ' *',
              style: style.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }
    return Text(text, style: style);
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    if (widget.obscureText) {
      return GestureDetector(
        onTap: () => setState(() => _obscured = !_obscured),
        child: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 22,
          color: _hintColor(context),
        ),
      );
    }
    return null;
  }
}
''';
}

/// Generates AppDropdownFormField — an adaptive overlay dropdown that
/// generates **two themed variants** (light + dark) in a single widget
/// that responds to the ambient ThemeData brightness.
///
/// Features:
/// - Floating label on the border (same pattern as AppTextFieldWithLabel)
/// - Single-open-at-a-time via DropdownController
/// - Smart up/down positioning based on available viewport space
/// - Auto-scroll to selected item
/// - `ValidationAckScope` support
String generateAppDropdownFormField(BlueprintConfig config) {
  return r'''
import 'package:flutter/material.dart';

import '../widgets/validation_ack_scope.dart';

// ────────────────────────────────────────────────────────────────────────────
// Global controller — ensures only one dropdown is open at a time
// ────────────────────────────────────────────────────────────────────────────

class _DropdownController {
  static _AppDropdownBodyState? _active;

  static void register(_AppDropdownBodyState d) {
    if (_active != null && _active != d) _active!._closeExternally();
    _active = d;
  }

  static void unregister(_AppDropdownBodyState d) {
    if (_active == d) _active = null;
  }

  static void closeActive() {
    _active?._closeExternally();
    _active = null;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Public form-field wrapper
// ────────────────────────────────────────────────────────────────────────────

/// An overlay-based dropdown that floats above the Scaffold, avoids
/// the keyboard, and adapts to the app's ThemeMode automatically.
///
/// Example:
/// ```dart
/// AppDropdownFormField<String>(
///   label: 'Country',
///   items: countries
///       .map((c) => DropdownMenuItem(value: c, child: Text(c)))
///       .toList(),
///   value: selectedCountry,
///   isRequired: true,
///   onChanged: (v) => setState(() => selectedCountry = v),
/// )
/// ```
class AppDropdownFormField<T> extends FormField<T> {
  AppDropdownFormField({
    super.key,
    required String label,
    required List<DropdownMenuItem<T>> items,
    T? value,
    FormFieldValidator<T>? validator,
    void Function(T?)? onChanged,
    String? hint,
    bool isRequired = true,
    IconData? prefixIcon,
    super.enabled,
    bool isLoading = false,
    double? maxHeight,
  }) : super(
          validator: isRequired && validator == null
              ? (v) => v == null ? 'Please select $label' : null
              : validator,
          initialValue: value,
          builder: (FormFieldState<T> state) {
            final ackScope = ValidationAckScope.maybeOf(state.context);
            if (ackScope != null &&
                ackScope.hideInlineErrors &&
                state.hasError &&
                state.errorText != null) {
              ackScope.controller.add(state.errorText!);
            }

            return _AppDropdownBody<T>(
              label: label,
              items: items,
              value: state.value,
              errorText: (ackScope?.hideInlineErrors ?? false)
                  ? null
                  : state.errorText,
              hint: hint,
              isRequired: isRequired,
              prefixIcon: prefixIcon,
              enabled: enabled,
              isLoading: isLoading,
              maxHeight: maxHeight,
              onChanged: (v) {
                state.didChange(v);
                onChanged?.call(v);
              },
            );
          },
        );
}

// ────────────────────────────────────────────────────────────────────────────
// Internal stateful body
// ────────────────────────────────────────────────────────────────────────────

class _AppDropdownBody<T> extends StatefulWidget {
  const _AppDropdownBody({
    required this.label,
    required this.items,
    required this.value,
    required this.errorText,
    required this.onChanged,
    this.hint,
    this.isRequired = false,
    this.prefixIcon,
    this.enabled = true,
    this.isLoading = false,
    this.maxHeight,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String? errorText;
  final String? hint;
  final bool isRequired;
  final IconData? prefixIcon;
  final bool enabled;
  final bool isLoading;
  final double? maxHeight;
  final ValueChanged<T?> onChanged;

  @override
  State<_AppDropdownBody<T>> createState() => _AppDropdownBodyState<T>();
}

class _AppDropdownBodyState<T> extends State<_AppDropdownBody<T>> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;
  final ScrollController _scroll = ScrollController();
  bool _expanded = false;
  bool _below = true;

  static const double _itemH = 48.0;
  static const double _maxFraction = 0.45;
  static const double _borderWidth = 2.0;
  static const double _radius = 10.0;

  // ── theme helpers ────────────────────────────────────────────────────────
  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _fill => _isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _text => _isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get _hint => _isDark ? Colors.white38 : const Color(0xFF9E9E9E);
  Color get _border => _isDark ? Colors.white70 : Colors.black;
  Color get _accent => Theme.of(context).colorScheme.primary;
  Color get _activeBorder =>
      widget.errorText != null ? Theme.of(context).colorScheme.error : _border;

  void _toggle() {
    if (!widget.enabled || widget.isLoading || widget.items.isEmpty) return;
    if (_expanded) {
      _close();
    } else {
      _open();
    }
  }

  void _closeExternally() {
    if (_expanded) {
      _removeOverlay();
      if (mounted) setState(() => _expanded = false);
    }
  }

  void _open() {
    _DropdownController.register(this);
    _insertOverlay();
    setState(() => _expanded = true);
  }

  void _close() {
    _DropdownController.unregister(this);
    _removeOverlay();
    setState(() => _expanded = false);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _insertOverlay() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject()! as RenderBox;
    final size = box.size;
    final off = box.localToGlobal(Offset.zero);
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final kbH = mq.viewInsets.bottom;
    final topPad = mq.padding.top;

    final spaceBelow = screenH - (off.dy + size.height) - kbH - 4;
    final spaceAbove = off.dy - topPad - 4;
    final contentH = widget.items.length * _itemH;

    _below = spaceBelow >= contentH
        ? true
        : spaceAbove >= contentH
            ? false
            : spaceBelow >= spaceAbove;

    final maxH = widget.maxHeight ?? (screenH * _maxFraction);
    final available = _below ? spaceBelow : spaceAbove;
    final dynH = contentH.clamp(0.0, available).clamp(0.0, maxH);

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _DropdownController.closeActive,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: _below ? const Offset(0, -2) : const Offset(0, 2),
            targetAnchor: _below ? Alignment.bottomLeft : Alignment.topLeft,
            followerAnchor: _below ? Alignment.topLeft : Alignment.bottomLeft,
            child: SizedBox(
              width: size.width,
              height: dynH,
              child: Material(
                color: Colors.transparent,
                child: _buildList(dynH),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlay!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final idx = widget.items.indexWhere((i) => i.value == widget.value);
      if (idx != -1) {
        final target = (idx * _itemH)
            .clamp(0.0, _scroll.position.maxScrollExtent);
        _scroll.jumpTo(target);
      }
    });
  }

  @override
  void dispose() {
    _DropdownController.unregister(this);
    _removeOverlay();
    _scroll.dispose();
    super.dispose();
  }

  // ── header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final selected = widget.items.firstWhere(
      (i) => i.value == widget.value,
      orElse: () => DropdownMenuItem(value: null, child: const SizedBox()),
    );

    Widget display;
    if (widget.value == null || selected.value == null) {
      display = Text(
        widget.hint ?? widget.label,
        style: TextStyle(color: _hint, fontWeight: FontWeight.w600, fontSize: 16),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    } else {
      final child = selected.child;
      final labelText = child is Text
          ? (child.data ?? child.textSpan?.toPlainText() ?? '')
          : null;
      display = labelText != null
          ? Text(
              labelText,
              style: TextStyle(color: _text, fontWeight: FontWeight.w600, fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          : DefaultTextStyle.merge(
              style: TextStyle(color: _text, fontSize: 16),
              child: child,
            );
    }

    // Border: drop bottom edge when expanded (merges visually with list)
    final border = _expanded
        ? Border(
            top: BorderSide(color: _activeBorder, width: _borderWidth),
            left: BorderSide(color: _activeBorder, width: _borderWidth),
            right: BorderSide(color: _activeBorder, width: _borderWidth),
            bottom: _below ? BorderSide.none : BorderSide(color: _activeBorder, width: _borderWidth),
          )
        : Border.all(color: _activeBorder, width: _borderWidth);

    final corners = BorderRadius.only(
      topLeft: const Radius.circular(_radius),
      topRight: const Radius.circular(_radius),
      bottomLeft: Radius.circular(_expanded && _below ? 0 : _radius),
      bottomRight: Radius.circular(_expanded && _below ? 0 : _radius),
    );

    return Container(
      height: 54,
      decoration: BoxDecoration(color: _fill, borderRadius: corners, border: border),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_accent),
                    ),
                  )
                : Icon(widget.prefixIcon, color: _text, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(child: display),
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: _text, size: 24),
          ),
        ],
      ),
    );
  }

  // ── list ─────────────────────────────────────────────────────────────────

  Widget _buildList(double height) {
    final totalH = widget.items.length * _itemH;
    final needsScroll = totalH > height;

    final corners = BorderRadius.only(
      bottomLeft: Radius.circular(_below ? _radius : 0),
      bottomRight: Radius.circular(_below ? _radius : 0),
      topLeft: Radius.circular(_below ? 0 : _radius),
      topRight: Radius.circular(_below ? 0 : _radius),
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: corners,
        border: Border.all(color: _border, width: _borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Scrollbar(
        controller: _scroll,
        thumbVisibility: needsScroll,
        child: ListView.separated(
          controller: _scroll,
          primary: false,
          shrinkWrap: true,
          physics: needsScroll
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: widget.items.length,
          separatorBuilder: (_, __) => Divider(
            color: _border.withValues(alpha: 0.2),
            thickness: 1,
            height: 1,
          ),
          itemBuilder: (_, i) {
            final isSelected = widget.items[i].value == widget.value;
            return InkWell(
              onTap: () {
                widget.onChanged(widget.items[i].value);
                _close();
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: _itemH),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                color: isSelected ? _accent.withValues(alpha: 0.1) : Colors.transparent,
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: isSelected ? _accent : _text,
                    fontSize: 15,
                  ),
                  child: widget.items[i].child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return CompositedTransformTarget(
      link: _link,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(onTap: _toggle, child: _buildHeader()),
              // Floating label on border
              Positioned(
                left: 12,
                top: -9,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  color: _fill,
                  child: widget.isRequired
                      ? RichText(
                          text: TextSpan(
                            text: widget.label,
                            style: TextStyle(
                              color: hasError
                                  ? Theme.of(context).colorScheme.error
                                  : _border,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          widget.label,
                          style: TextStyle(
                            color: hasError
                                ? Theme.of(context).colorScheme.error
                                : _border,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
''';
}

/// Generates the improved LoggerInterceptor that routes through AppLogger
/// instead of using raw print() calls. This is the version that replaces the
/// basic stub generated in api/interceptors/logger_interceptor.dart.
String generateLoggerInterceptor(BlueprintConfig config) {
  return """import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Pretty-printing Dio interceptor that routes all output through [AppLogger].
///
/// Logs:
/// - **REQUEST** — method, URL, headers, query params, JSON body (indented)
/// - **RESPONSE** — status code, URL, JSON body (indented)
/// - **ERROR** — type, message, status code, error body
///
/// All output is suppressed in release mode because [AppLogger] wraps
/// everything in `kDebugMode` guards.
class LoggerInterceptor extends Interceptor {
  static const _tag = 'HTTP';
  static const _line =
      '─────────────────────────────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('┌\$_line', _tag);
    AppLogger.debug(
      '│ ► \${options.method.toUpperCase()} '
      '\${options.baseUrl}\${options.path}',
      _tag,
    );
    AppLogger.debug('├\$_line', _tag);

    if (options.headers.isNotEmpty) {
      AppLogger.debug('│ 📋 Headers:', _tag);
      options.headers.forEach((k, v) => AppLogger.debug('│   \$k: \$v', _tag));
      AppLogger.debug('├\$_line', _tag);
    }

    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug('│ 🔍 Query:', _tag);
      options.queryParameters
          .forEach((k, v) => AppLogger.debug('│   \$k: \$v', _tag));
      AppLogger.debug('├\$_line', _tag);
    }

    if (options.data != null) {
      AppLogger.debug('│ 📤 Body:', _tag);
      _prettyJson(options.data)
          .forEach((line) => AppLogger.debug('│   \$line', _tag));
      AppLogger.debug('├\$_line', _tag);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.success(
      '│ ✅ \${response.statusCode} '
      '\${response.requestOptions.baseUrl}\${response.requestOptions.path}',
      _tag,
    );

    if (response.data != null) {
      AppLogger.debug('├\$_line', _tag);
      AppLogger.debug('│ 📥 Response Body:', _tag);
      _prettyJson(response.data)
          .forEach((line) => AppLogger.debug('│   \$line', _tag));
    }

    AppLogger.debug('└\$_line', _tag);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '│ ❌ \${err.type.name.toUpperCase()} '
      '\${err.requestOptions.baseUrl}\${err.requestOptions.path}',
      err,
      err.stackTrace,
      _tag,
    );

    if (err.message != null) {
      AppLogger.warning('│ 💬 \${err.message}', _tag);
    }

    if (err.response != null) {
      AppLogger.warning(
          '│ 📊 Status: \${err.response!.statusCode}', _tag);
      if (err.response!.data != null) {
        AppLogger.debug('│ 📥 Error Body:', _tag);
        _prettyJson(err.response!.data)
            .forEach((line) => AppLogger.debug('│   \$line', _tag));
      }
    }

    AppLogger.debug('└\$_line', _tag);
    super.onError(err, handler);
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  List<String> _prettyJson(dynamic data) {
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(data).split('\\n');
    } catch (_) {
      return [data.toString()];
    }
  }
}
""";
}

/// Generates AppResponsive — a zero-dependency responsive utility that scales
/// sizes, fonts, paddings, and radii against a base design canvas
/// (390×844, iPhone 14 Pro).
///
/// Also replaces ContextExtensions with a richer version that exposes every
/// AppResponsive helper directly on BuildContext.
String generateAppResponsive(BlueprintConfig config) {
  return r'''
import 'package:flutter/material.dart';

/// Zero-dependency responsive utility.
///
/// Base design canvas: **390 × 844** (iPhone 14 Pro).
/// All scaling is proportional to the actual device screen size, so every
/// pixel value you pass is relative to that 390-wide mockup.
///
/// Quick-reference:
/// ```
/// AppResponsive.s(context, 16)   // scale a generic pixel value
/// AppResponsive.font(context, 16) // scale a font size
/// AppResponsive.p(context, 16)   // scale a padding value
/// AppResponsive.sh(context, 100) // scale based on HEIGHT ratio
/// context.rs(16)                 // shorthand via extension
/// context.rFont(16)
/// context.rVSpace(24)            // SizedBox(height: …) helper
/// ```
class AppResponsive {
  AppResponsive._();

  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  // ── Breakpoints ────────────────────────────────────────────────────────────

  /// Any device narrower than this is considered a phone.
  static const double mobileBreak = 600.0;

  /// Devices at or above this width are considered desktop.
  static const double desktopBreak = 1200.0;

  // ── Raw percentage helpers ─────────────────────────────────────────────────

  /// Returns [percentage] * screenWidth.  e.g. `w(ctx, 0.5)` = 50% of width.
  static double w(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.width * percentage;

  /// Returns [percentage] * screenHeight.
  static double h(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.height * percentage;

  // ── Linear scaling ─────────────────────────────────────────────────────────

  /// Scales [px] linearly from the 390-wide base design to the actual screen.
  /// Use this for widths, icon sizes, spacers, and most widget dimensions.
  static double s(BuildContext context, double px) {
    final screenWidth = MediaQuery.of(context).size.width;
    return px * (screenWidth / _baseWidth);
  }

  /// Scales [px] based on the screen HEIGHT ratio (844-base).
  /// Use for vertical paddings that must stay proportional on tall/short screens.
  static double sh(BuildContext context, double px) {
    final screenHeight = MediaQuery.of(context).size.height;
    return px * (screenHeight / _baseHeight);
  }

  // ── Named semantic wrappers ────────────────────────────────────────────────

  /// Scale a font size. Delegates to [s] (width-ratio scaling).
  static double font(BuildContext context, double px) => s(context, px);

  /// Scale a padding / margin value.
  static double p(BuildContext context, double px) => s(context, px);

  /// Scale a border radius.
  static double radius(BuildContext context, double px) => s(context, px);

  /// Scale an icon size.
  static double icon(BuildContext context, double px) => s(context, px);

  /// Scale a border / divider thickness.
  static double thickness(BuildContext context, double px) => s(context, px);

  // ── EdgeInsets helpers ─────────────────────────────────────────────────────

  /// Returns scaled [EdgeInsets].
  ///
  /// Pass [all] for uniform insets, or individual sides for asymmetric insets.
  static EdgeInsets padding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) return EdgeInsets.all(s(context, all));
    return EdgeInsets.only(
      left: s(context, left ?? horizontal ?? 0),
      top: s(context, top ?? vertical ?? 0),
      right: s(context, right ?? horizontal ?? 0),
      bottom: s(context, bottom ?? vertical ?? 0),
    );
  }

  /// Returns symmetric scaled [EdgeInsets].
  static EdgeInsets paddingSymmetric(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: s(context, horizontal),
        vertical: s(context, vertical),
      );

  // ── BorderRadius helpers ───────────────────────────────────────────────────

  /// Returns [BorderRadius.circular] with a scaled radius.
  static BorderRadius borderRadius(BuildContext context, double px) =>
      BorderRadius.circular(radius(context, px));

  // ── SizedBox gap helpers ───────────────────────────────────────────────────

  /// Returns a [SizedBox] with a responsive **width** for horizontal gaps.
  static SizedBox horizontalSpace(BuildContext context, double px) =>
      SizedBox(width: s(context, px));

  /// Returns a [SizedBox] with a responsive **height** for vertical gaps.
  static SizedBox verticalSpace(BuildContext context, double px) =>
      SizedBox(height: s(context, px));

  // ── Device-type detection ──────────────────────────────────────────────────

  /// `true` when the shortest side is ≥ 600 dp (tablet).
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= mobileBreak;

  /// `true` when width ≥ 1200 dp (desktop / large tablet landscape).
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreak;

  /// Returns the current [AppDeviceType] based on screen width.
  static AppDeviceType deviceType(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= desktopBreak) return AppDeviceType.desktop;
    if (w >= mobileBreak) return AppDeviceType.tablet;
    return AppDeviceType.mobile;
  }

  // ── Responsive value picker ────────────────────────────────────────────────

  /// Returns different values for mobile / tablet / desktop.
  /// Falls back to narrower variants when broader ones are null.
  ///
  /// ```dart
  /// final cols = AppResponsive.value(context, mobile: 2, tablet: 3, desktop: 4);
  /// ```
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType(context)) {
      case AppDeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case AppDeviceType.tablet:
        return tablet ?? mobile;
      case AppDeviceType.mobile:
        return mobile;
    }
  }
}

/// Device-type enum used by [AppResponsive.deviceType].
enum AppDeviceType { mobile, tablet, desktop }

// ── BuildContext extension ────────────────────────────────────────────────────

/// Convenience extension so you can write `context.rs(16)` instead of
/// `AppResponsive.s(context, 16)`.
extension ResponsiveContext on BuildContext {
  // ── theme helpers (keep from original ContextExtensions) ────────────────
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // ── backward-compat aliases (match old ContextExtensions) ───────────────
  /// @deprecated Use [screenWidth] instead.
  double get width => screenWidth;

  /// @deprecated Use [screenHeight] instead.
  double get height => screenHeight;

  // ── snackbar helper ──────────────────────────────────────────────────────
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : null,
      ),
    );
  }

  // ── device type ─────────────────────────────────────────────────────────
  bool get isTablet => AppResponsive.isTablet(this);
  bool get isDesktop => AppResponsive.isDesktop(this);
  AppDeviceType get deviceType => AppResponsive.deviceType(this);

  // ── scaling helpers ──────────────────────────────────────────────────────
  /// Scale a pixel value (width-ratio).
  double rs(double px) => AppResponsive.s(this, px);

  /// Scale a pixel value (height-ratio).
  double rsh(double px) => AppResponsive.sh(this, px);

  /// Scale a font size.
  double rFont(double px) => AppResponsive.font(this, px);

  /// Scale a padding / margin value.
  double rPadding(double px) => AppResponsive.p(this, px);

  /// Scale a border radius.
  double rRadius(double px) => AppResponsive.radius(this, px);

  /// Scale an icon size.
  double rIcon(double px) => AppResponsive.icon(this, px);

  /// Scale a border thickness.
  double rThickness(double px) => AppResponsive.thickness(this, px);

  // ── EdgeInsets helpers ───────────────────────────────────────────────────
  EdgeInsets rPaddingAll(double px) => AppResponsive.padding(this, all: px);
  EdgeInsets rPaddingH(double px) =>
      AppResponsive.padding(this, horizontal: px);
  EdgeInsets rPaddingV(double px) => AppResponsive.padding(this, vertical: px);
  EdgeInsets rPaddingSymmetric({double h = 0, double v = 0}) =>
      AppResponsive.paddingSymmetric(this, horizontal: h, vertical: v);

  // ── BorderRadius ─────────────────────────────────────────────────────────
  BorderRadius rBorderRadius(double px) =>
      AppResponsive.borderRadius(this, px);

  // ── SizedBox gap helpers ─────────────────────────────────────────────────
  SizedBox rHSpace(double px) => AppResponsive.horizontalSpace(this, px);
  SizedBox rVSpace(double px) => AppResponsive.verticalSpace(this, px);

  // ── responsive value picker ──────────────────────────────────────────────
  T rValue<T>({required T mobile, T? tablet, T? desktop}) =>
      AppResponsive.value(this, mobile: mobile, tablet: tablet, desktop: desktop);
}
''';
}
