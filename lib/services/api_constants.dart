class ApiConstants {
  static const String baseUrl = 'https://api.thecatapi.com/v1';

  static const String apiKey =
      'live_cW7sQ321OyQADxaPb5uOq7sR4BSR9FZYAJczBSMAeiLgL7i6PPEZK8YrYmp0CJDo';

  static const String imagesSearch = '/images/search';
  static const String breeds = '/breeds';

  static Map<String, String> get headers => {
    'x-api-key': apiKey,
    'Content-Type': 'application/json',
  };
}
