class ApiConstants {
  static const String baseUrl = 'https://api.thecatapi.com/v1';

  static const String apiKey = String.fromEnvironment('CAT_API_KEY');

  static const String imagesSearch = '/images/search';
  static const String breeds = '/breeds';

  static Map<String, String> get headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (apiKey.isNotEmpty) {
      h['x-api-key'] = apiKey;
    }
    return h;
  }
}
