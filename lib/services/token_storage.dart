import 'token_storage_stub.dart'
    if (dart.library.js_interop) 'token_storage_web.dart'
    as storage_impl;

class TokenStorage {
  static Future<void> saveToken(String token) => storage_impl.saveToken(token);
  static Future<String?> getToken() => storage_impl.getToken();
  static Future<void> clearToken() => storage_impl.clearToken();
}
