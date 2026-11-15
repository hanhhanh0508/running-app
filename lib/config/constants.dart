import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      // Khi chạy trên Trình duyệt Web (Chrome / Edge)
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      // Khi chạy trên Máy ảo Android Emulator
      return 'http://10.0.2.2:5000/api';
    } else {
      // Các trường hợp còn lại (Windows app / iOS / macOS)
      return 'http://localhost:5000/api';
    }
  }
}