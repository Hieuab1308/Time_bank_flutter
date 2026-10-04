import 'package:http/http.dart' as http;
import '../app_config.dart';
import 'api_client.dart';

class AuthApiClient extends ApiClient {
  AuthApiClient(http.Client authedClient, AppConfig config) : super(authedClient, config);
}
