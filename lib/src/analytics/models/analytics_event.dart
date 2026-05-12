class AnalyticsEvent {
  final String eventId;
  final String event;
  final String anonymousId;
  final String platform;
  final String timestamp;
  final String? sessionId;
  final String? userId;
  final String? sdkVersion;
  final String? appVersion;
  final Map<String, dynamic>? properties;
  final AnalyticsDeviceInfo? deviceInfo;

  const AnalyticsEvent({
    required this.eventId,
    required this.event,
    required this.anonymousId,
    required this.platform,
    required this.timestamp,
    this.sessionId,
    this.userId,
    this.sdkVersion,
    this.appVersion,
    this.properties,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'event': event,
        'anonymous_id': anonymousId,
        'platform': platform,
        'timestamp': timestamp,
        if (sessionId != null) 'session_id': sessionId,
        if (userId != null) 'user_id': userId,
        if (sdkVersion != null) 'sdk_version': sdkVersion,
        if (appVersion != null) 'app_version': appVersion,
        if (properties != null) 'properties': properties,
        if (deviceInfo != null) 'device_info': deviceInfo!.toJson(),
      };
}

class AnalyticsDeviceInfo {
  final String? model;
  final String? os;
  final String? osVersion;
  final String? brand;
  final String? locale;
  final String? timezone;
  final bool? isTablet;
  final int? screenWidth;
  final int? screenHeight;

  const AnalyticsDeviceInfo({
    this.model,
    this.os,
    this.osVersion,
    this.brand,
    this.locale,
    this.timezone,
    this.isTablet,
    this.screenWidth,
    this.screenHeight,
  });

  Map<String, dynamic> toJson() => {
        if (model != null) 'model': model,
        if (os != null) 'os': os,
        if (osVersion != null) 'os_version': osVersion,
        if (brand != null) 'brand': brand,
        if (locale != null) 'locale': locale,
        if (timezone != null) 'timezone': timezone,
        if (isTablet != null) 'is_tablet': isTablet,
        if (screenWidth != null) 'screen_width': screenWidth,
        if (screenHeight != null) 'screen_height': screenHeight,
      };
}
