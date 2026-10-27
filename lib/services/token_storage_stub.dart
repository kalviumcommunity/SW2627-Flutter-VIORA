String? _inMemoryToken;

Future<void> saveToken(String token) async {
  _inMemoryToken = token;
}

Future<String?> getToken() async {
  return _inMemoryToken;
}

Future<void> clearToken() async {
  _inMemoryToken = null;
}
