import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_http_client.dart';
import '../../../core/network/auth_api_client.dart';

import '../domain/i_auth_api.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';
import '../domain/user_profile.dart';
import 'dart:convert';

/// App config (only one)
final appConfigProvider = Provider<AppConfig>((_) => AppConfig.fromEnv);

/// Base http (trần)
final baseHttpProvider = Provider<http.Client>((_) => http.Client());

/// ApiClient KHÔNG auth – dùng cho /auth/login, /auth/refresh, public API
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(baseHttpProvider), ref.read(appConfigProvider));
});

/// AuthApi (implements IAuthApi) – dùng ApiClient (không cần Bearer)
final authApiProvider = Provider<IAuthApi>((ref) {
  return AuthApi(ref.read(apiClientProvider));
});


final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
      ref.read(authApiProvider),
      const FlutterSecureStorage()
  );
});

/// HTTP client có Bearer + auto refresh
final authedHttpProvider = Provider<http.Client>((ref) {
  final repo = ref.read(authRepoProvider);
  final cfg  = ref.read(appConfigProvider);
  return AuthHttpClient(ref.read(baseHttpProvider), repo, apiBase: cfg.apiBase);
});

/// ApiClient có auth – dùng cho mọi API cần login
final authedApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(ref.read(authedHttpProvider), ref.read(appConfigProvider));
});

/// Auth controller
final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>((ref) {

  final controller = AuthController(ref, ref.read(authRepoProvider));

  controller.signOut().catchError((e) {});

  return controller;
});

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  // 1. Lắng nghe trạng thái xác thực TỪ AuthController
  final isAuthenticated = ref.watch(authControllerProvider.select((s) => s.authenticated));

  // 2. Nếu chưa đăng nhập, ném lỗi ngay
  if (!isAuthenticated) {
    throw Exception('Chưa đăng nhập');
  }

  // 3. Lấy client ĐÃ XÁC THỰC
  final authedApi = ref.watch(authedApiClientProvider);

  // 4. Tự gọi API (Sẽ chạy lại khi isAuthenticated = true)
  final res = await authedApi.get('/users/me');

  // 5. Tự check lỗi
  if (res.statusCode < 200 || res.statusCode >= 300) {
    try {
      final errorBody = json.decode(utf8.decode(res.bodyBytes));
      throw Exception(errorBody['message'] ?? 'Lỗi ${res.statusCode}');
    } catch (e) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  // 6. Tự parse
  final body = json.decode(utf8.decode(res.bodyBytes));
  return UserProfile.fromJson(body);
});