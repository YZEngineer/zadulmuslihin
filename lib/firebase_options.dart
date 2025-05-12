// ملف مؤقت - سيتم استبداله بالملف الصحيح عند تكوين Firebase

/// خيارات Firebase الافتراضية - نسخة مؤقتة مبسطة
class DefaultFirebaseOptions {
  /// الحصول على الخيارات الحالية للمنصة
  static Map<String, String> get currentPlatform {
    return {
      'apiKey': 'dummy-api-key',
      'appId': 'dummy-app-id',
      'messagingSenderId': 'dummy-sender-id',
      'projectId': 'dummy-project-id',
    };
  }
}
