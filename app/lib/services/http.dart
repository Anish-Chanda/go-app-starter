import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/constants.dart';

// Singleton HTTP client with persistent cookie jar
// This will automatically handle auth cookies given by the backend and persist them across app restarts
class HttpClient {
  HttpClient._();
  static final HttpClient instance = HttpClient._();
  late Dio dio;
  late final PersistCookieJar cookieJar;
  bool _initialized = false;

  // Initialize the HTTP client with the API base URL
  // Must be called before making any API requests
  Future<void> init({String? baseUrl, String? testCookieDir}) async {
    if (_initialized) return;

    // Figure out cookie path
    final cookiesPath =
        testCookieDir ??
        (await (() async {
          final appDocDir = await getApplicationDocumentsDirectory();
          return '${appDocDir.path}/.cookies/';
        })());

    // Create persistent cookie jar
    cookieJar = PersistCookieJar(
      ignoreExpires: false,
      storage: FileStorage(cookiesPath),
    );

    // Create dio with base url
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? API_BASE_URL,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add cookie manager interceptor
    dio.interceptors.add(CookieManager(cookieJar));

    // Add error interceptor for better error handling
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // You can add custom error handling here
          // For example, refresh tokens, log errors, etc.
          return handler.next(error);
        },
      ),
    );

    _initialized = true;
  }

  // Clear all stored cookies (useful for logout)
  Future<void> clearCookies() async {
    await cookieJar.deleteAll();
  }

  // Check if the client is initialized
  bool get isInitialized => _initialized;
}
