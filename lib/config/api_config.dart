class ApiConfig {
  static const String baseUrl = 'https://admin.maximus.works/admin/api';
  static const int timeoutSeconds = 10;
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
}
