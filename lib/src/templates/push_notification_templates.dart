import 'package:path/path.dart' as p;
import '../config/blueprint_config.dart';

/// Generates Push Notification templates for FCM/APNs integration.
class PushNotificationTemplates {
  /// Generates all push notification-related files
  static Map<String, String> generate(BlueprintConfig config) {
    final files = <String, String>{};
    final appName = config.appName;

    files[p.join(
            'lib', 'core', 'notifications', 'push_notification_service.dart')] =
        _pushNotificationService(appName);
    files[p.join('lib', 'core', 'notifications',
            'local_notification_service.dart')] =
        _localNotificationService(appName);
    files[p.join('lib', 'core', 'notifications', 'notification_handler.dart')] =
        _notificationHandler(appName);
    files[p.join(
            'lib', 'core', 'notifications', 'notification_permission.dart')] =
        _notificationPermission(appName);

    return files;
  }

  /// Returns the dependencies required for push notifications
  static Map<String, String> getDependencies() {
    return {
      'firebase_messaging': '^15.1.0',
      'flutter_local_notifications': '^17.2.0',
    };
  }

  static String _pushNotificationService(String appName) => '''
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_handler.dart';

/// Service for handling Firebase Cloud Messaging (FCM) push notifications.
class PushNotificationService {
  PushNotificationService({
    NotificationHandler? handler,
  }) : _handler = handler ?? NotificationHandler();

  final NotificationHandler _handler;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  StreamSubscription? _foregroundSubscription;
  StreamSubscription? _tokenRefreshSubscription;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Stream of FCM token updates
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Initialize the push notification service
  Future<void> initialize() async {
    // Get initial FCM token
    _fcmToken = await _messaging.getToken();
    
    // Listen for token refresh
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _onTokenRefresh(token);
    });

    // Handle foreground messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Request notification permissions (required for iOS)
  Future<NotificationSettings> requestPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    _handler.handleForegroundMessage(message);
  }

  /// Handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    _handler.handleNotificationTap(message);
  }

  /// Called when FCM token is refreshed
  void _onTokenRefresh(String token) {
    // Override this to send the new token to your server
    // Example: api.updateFcmToken(token);
  }

  /// Dispose of the service
  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
  }
}

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  // Note: You cannot use UI here, only background processing
  print('Handling background message: \${message.messageId}');
}
''';

  static String _localNotificationService(String appName) => '''
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for displaying local notifications.
class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Callback for when a notification is tapped
  Function(NotificationResponse)? onNotificationTap;

  /// Initialize the local notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response);
      },
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'Default notification channel',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show a notification
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_channel',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Default Notifications',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Notifications scheduled for later',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
''';

  static String _notificationHandler(String appName) => '''
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart';

/// Handles notification display and navigation.
class NotificationHandler {
  NotificationHandler({
    LocalNotificationService? localNotifications,
  }) : _localNotifications = localNotifications ?? LocalNotificationService();

  final LocalNotificationService _localNotifications;

  /// Callback for handling notification tap navigation
  Function(Map<String, dynamic> data)? onNavigate;

  /// Initialize the handler
  Future<void> initialize() async {
    await _localNotifications.initialize();
    _localNotifications.onNotificationTap = _handleLocalNotificationTap;
  }

  /// Handle foreground messages by showing a local notification
  void handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    
    if (notification != null) {
      _localNotifications.show(
        id: message.hashCode,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: _encodePayload(message.data),
      );
    }
  }

  /// Handle notification tap from push notification
  void handleNotificationTap(RemoteMessage message) {
    _navigate(message.data);
  }

  /// Handle notification tap from local notification
  void _handleLocalNotificationTap(dynamic response) {
    final payload = response.payload;
    if (payload != null) {
      final data = _decodePayload(payload as String);
      _navigate(data);
    }
  }

  /// Navigate based on notification data
  void _navigate(Map<String, dynamic> data) {
    onNavigate?.call(data);
    
    // Example navigation logic:
    // final route = data['route'] as String?;
    // if (route != null) {
    //   Navigator.pushNamed(context, route, arguments: data);
    // }
  }

  /// Encode notification data to payload string
  String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '\${e.key}=\${e.value}').join('&');
  }

  /// Decode payload string to data map
  Map<String, dynamic> _decodePayload(String payload) {
    final pairs = payload.split('&');
    return Map.fromEntries(
      pairs.map((pair) {
        final parts = pair.split('=');
        return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
      }),
    );
  }
}
''';

  static String _notificationPermission(String appName) => '''
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Manages notification permissions across platforms.
class NotificationPermission {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Check if notifications are enabled
  Future<bool> isEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permissions
  Future<PermissionResult> request() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return PermissionResult(
      status: _mapStatus(settings.authorizationStatus),
      settings: settings,
    );
  }

  /// Request provisional notification permissions (iOS only)
  /// Provisional notifications are delivered quietly without prompting
  Future<PermissionResult> requestProvisional() async {
    if (!Platform.isIOS) {
      return request();
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    return PermissionResult(
      status: _mapStatus(settings.authorizationStatus),
      settings: settings,
    );
  }

  PermissionStatus _mapStatus(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return PermissionStatus.granted;
      case AuthorizationStatus.denied:
        return PermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return PermissionStatus.notDetermined;
      case AuthorizationStatus.provisional:
        return PermissionStatus.provisional;
    }
  }
}

/// Result of permission request
class PermissionResult {
  const PermissionResult({
    required this.status,
    required this.settings,
  });

  final PermissionStatus status;
  final NotificationSettings settings;

  bool get isGranted => status == PermissionStatus.granted;
  bool get isDenied => status == PermissionStatus.denied;
  bool get isProvisional => status == PermissionStatus.provisional;
}

/// Notification permission status
enum PermissionStatus {
  /// Permission has been granted
  granted,

  /// Permission has been denied
  denied,

  /// Permission has not been requested yet
  notDetermined,

  /// Provisional permission (iOS only)
  provisional,
}
''';
}
