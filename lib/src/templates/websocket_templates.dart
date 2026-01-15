import 'package:path/path.dart' as p;
import '../config/blueprint_config.dart';

/// Generates WebSocket support templates for real-time communication.
class WebSocketTemplates {
  /// Generates all WebSocket-related files
  static Map<String, String> generate(BlueprintConfig config) {
    final files = <String, String>{};
    final appName = config.appName;

    files[p.join('lib', 'core', 'websocket', 'websocket_client.dart')] =
        _websocketClient(appName);
    files[p.join('lib', 'core', 'websocket', 'websocket_channel.dart')] =
        _websocketChannel(appName);
    files[p.join('lib', 'core', 'websocket', 'websocket_message.dart')] =
        _websocketMessage(appName);
    files[p.join('lib', 'core', 'websocket', 'websocket_service.dart')] =
        _websocketService(appName);

    return files;
  }

  /// Returns the dependencies required for WebSocket support
  static Map<String, String> getDependencies() {
    return {
      'web_socket_channel': '^2.4.0',
    };
  }

  static String _websocketClient(String appName) => '''
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket client with automatic reconnection and message queuing.
class WebSocketClient {
  WebSocketClient({
    required this.url,
    this.reconnectInterval = const Duration(seconds: 5),
    this.maxReconnectAttempts = 10,
  });

  final String url;
  final Duration reconnectInterval;
  final int maxReconnectAttempts;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  int _reconnectAttempts = 0;
  bool _isConnecting = false;
  bool _shouldReconnect = true;

  final _messageController = StreamController<dynamic>.broadcast();
  final _connectionStateController = StreamController<ConnectionState>.broadcast();
  final _messageQueue = <dynamic>[];

  /// Stream of incoming messages
  Stream<dynamic> get messages => _messageController.stream;

  /// Stream of connection state changes
  Stream<ConnectionState> get connectionState => _connectionStateController.stream;

  /// Current connection state
  ConnectionState _state = ConnectionState.disconnected;
  ConnectionState get state => _state;

  /// Whether the client is connected
  bool get isConnected => _state == ConnectionState.connected;

  /// Connect to the WebSocket server
  Future<void> connect() async {
    if (_isConnecting || isConnected) return;

    _isConnecting = true;
    _shouldReconnect = true;
    _updateState(ConnectionState.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;
      
      _reconnectAttempts = 0;
      _updateState(ConnectionState.connected);
      
      // Send queued messages
      _flushMessageQueue();
      
      // Listen for messages
      _subscription = _channel!.stream.listen(
        (data) => _messageController.add(data),
        onError: (error) {
          _messageController.addError(error);
          _handleDisconnect();
        },
        onDone: _handleDisconnect,
      );
    } catch (e) {
      _updateState(ConnectionState.error);
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    _shouldReconnect = false;
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _updateState(ConnectionState.disconnected);
  }

  /// Send a message to the server
  void send(dynamic message) {
    if (isConnected && _channel != null) {
      final data = message is String ? message : jsonEncode(message);
      _channel!.sink.add(data);
    } else {
      // Queue message for when connection is established
      _messageQueue.add(message);
    }
  }

  /// Send a JSON message to the server
  void sendJson(Map<String, dynamic> data) {
    send(jsonEncode(data));
  }

  void _updateState(ConnectionState newState) {
    _state = newState;
    _connectionStateController.add(newState);
  }

  void _handleDisconnect() {
    _updateState(ConnectionState.disconnected);
    _channel = null;
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _updateState(ConnectionState.failed);
      return;
    }

    _reconnectAttempts++;
    _updateState(ConnectionState.reconnecting);

    Future.delayed(reconnectInterval, () {
      if (_shouldReconnect) {
        connect();
      }
    });
  }

  void _flushMessageQueue() {
    while (_messageQueue.isNotEmpty && isConnected) {
      send(_messageQueue.removeAt(0));
    }
  }

  /// Dispose of the client and release resources
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _connectionStateController.close();
  }
}

/// WebSocket connection state
enum ConnectionState {
  /// Not connected to the server
  disconnected,
  
  /// Attempting to connect
  connecting,
  
  /// Connected to the server
  connected,
  
  /// Attempting to reconnect after disconnect
  reconnecting,
  
  /// Connection error occurred
  error,
  
  /// Failed to connect after max attempts
  failed,
}
''';

  static String _websocketChannel(String appName) => '''
import 'dart:async';
import 'websocket_client.dart';
import 'websocket_message.dart';

/// Represents a logical channel within a WebSocket connection.
/// Useful for routing messages to specific topics or rooms.
class WebSocketChannel {
  WebSocketChannel({
    required this.name,
    required this.client,
  });

  final String name;
  final WebSocketClient client;

  final _messageController = StreamController<WebSocketMessage>.broadcast();

  /// Stream of messages for this channel
  Stream<WebSocketMessage> get messages => _messageController.stream;

  /// Subscribe to this channel
  void subscribe() {
    client.sendJson({
      'action': 'subscribe',
      'channel': name,
    });
  }

  /// Unsubscribe from this channel
  void unsubscribe() {
    client.sendJson({
      'action': 'unsubscribe',
      'channel': name,
    });
  }

  /// Send a message to this channel
  void send(String event, Map<String, dynamic> data) {
    final message = WebSocketMessage(
      channel: name,
      event: event,
      data: data,
    );
    client.sendJson(message.toJson());
  }

  /// Handle an incoming message for this channel
  void handleMessage(WebSocketMessage message) {
    if (message.channel == name) {
      _messageController.add(message);
    }
  }

  /// Dispose of the channel
  Future<void> dispose() async {
    unsubscribe();
    await _messageController.close();
  }
}
''';

  static String _websocketMessage(String appName) => '''
import 'dart:convert';

/// Represents a WebSocket message with channel, event, and data.
class WebSocketMessage {
  WebSocketMessage({
    this.channel,
    required this.event,
    this.data,
    this.timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String? channel;
  final String event;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  /// Create a message from JSON
  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      channel: json['channel'] as String?,
      event: json['event'] as String,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Create a message from a raw string
  factory WebSocketMessage.fromString(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return WebSocketMessage.fromJson(json);
    } catch (_) {
      return WebSocketMessage(
        event: 'raw',
        data: {'message': raw},
      );
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (channel != null) 'channel': channel,
      'event': event,
      if (data != null) 'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => 'WebSocketMessage(channel: \$channel, event: \$event, data: \$data)';
}
''';

  static String _websocketService(String appName) => '''
import 'dart:async';
import 'websocket_client.dart';
import 'websocket_channel.dart';
import 'websocket_message.dart';

/// High-level WebSocket service for managing connections and channels.
class WebSocketService {
  WebSocketService({
    required String url,
  }) : _client = WebSocketClient(url: url);

  final WebSocketClient _client;
  final Map<String, WebSocketChannel> _channels = {};

  StreamSubscription? _messageSubscription;

  /// Stream of connection state changes
  Stream<ConnectionState> get connectionState => _client.connectionState;

  /// Whether the service is connected
  bool get isConnected => _client.isConnected;

  /// Initialize and connect the WebSocket service
  Future<void> connect() async {
    await _client.connect();
    
    // Route incoming messages to appropriate channels
    _messageSubscription = _client.messages.listen((data) {
      try {
        final message = data is String
            ? WebSocketMessage.fromString(data)
            : WebSocketMessage.fromJson(data as Map<String, dynamic>);
        
        if (message.channel != null && _channels.containsKey(message.channel)) {
          _channels[message.channel]!.handleMessage(message);
        }
      } catch (_) {
        // Handle parsing errors gracefully
      }
    });
  }

  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    await _messageSubscription?.cancel();
    for (final channel in _channels.values) {
      await channel.dispose();
    }
    _channels.clear();
    await _client.disconnect();
  }

  /// Get or create a channel by name
  WebSocketChannel channel(String name) {
    if (!_channels.containsKey(name)) {
      _channels[name] = WebSocketChannel(name: name, client: _client);
    }
    return _channels[name]!;
  }

  /// Subscribe to a channel
  WebSocketChannel subscribe(String channelName) {
    final ch = channel(channelName);
    ch.subscribe();
    return ch;
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channelName) {
    if (_channels.containsKey(channelName)) {
      _channels[channelName]!.unsubscribe();
      _channels.remove(channelName);
    }
  }

  /// Send a message directly through the client
  void send(String event, Map<String, dynamic> data) {
    final message = WebSocketMessage(event: event, data: data);
    _client.sendJson(message.toJson());
  }

  /// Dispose of the service
  Future<void> dispose() async {
    await disconnect();
    await _client.dispose();
  }
}
''';
}
