class AppConfig {
  const AppConfig({
    required this.apiBase,
    this.apiKey,
  });

  /// ex: http://10.3.129.2:3000/api/v1
  final String apiBase;

  /// nếu backend cần API key
  final String? apiKey;

  /// lấy từ --dart-define hoặc fallback
  static const AppConfig fromEnv = AppConfig(
    apiBase: String.fromEnvironment('API_BASE', defaultValue: 'http://10.1.130.153:3000/api/v1'),
    apiKey:  String.fromEnvironment('API_KEY',  defaultValue: ''), // để trống nếu không dùng
  );
}
