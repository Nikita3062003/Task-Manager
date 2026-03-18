import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://task-manager-jahe.onrender.com';
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }
}
