import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static Future<void> loadEnv() async {
    if (dotenv.isInitialized == false) {
      await dotenv.load(fileName: "assets/.env");
    }
  }

  static String getBaseUrl() {
    return dotenv.env['BASE_URL'] ?? 'http://default-url.com';
  }
}
