import 'package:web/web.dart' as web;

const String _tokenKey = 'viora_auth_token';

Future<void> saveToken(String token) async {
  try {
    web.window.localStorage.setItem(_tokenKey, token);
  } catch (_) {}
}

Future<String?> getToken() async {
  try {
    final token = web.window.localStorage.getItem(_tokenKey);
    if (token != null && token.isNotEmpty) {
      return token;
    }
  } catch (_) {}
  return null;
}

Future<void> clearToken() async {
  try {
    web.window.localStorage.removeItem(_tokenKey);
  } catch (_) {}
}
