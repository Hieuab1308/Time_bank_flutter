import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/i_auth_api.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  AuthTokens({required this.accessToken, required this.refreshToken});
}

class AuthRepository {
  AuthRepository(this.api, this.storage);
  final IAuthApi api;
  final FlutterSecureStorage storage;

  static const _kRefresh = 'refresh_token';

  String? _access; // giữ trong RAM
  String? get accessToken => _access;

  Future<Map<String, dynamic>> signIn({
    required String phone,
    required String password,
    String? deviceInfo,
  }) async {
    final data = await api.login(
      phone: phone,
      password: password,
      deviceInfo: deviceInfo,
    );

    final access = data['access_token'] as String?;
    final refresh = data['refresh_token'] as String?;
    if (access != null) _access = access;
    if (refresh != null) {
      await storage.write(key: _kRefresh, value: refresh);
    }
    return data;
  }

  /// Đăng xuất...
  Future<void> signOut() async {
    final r = await storage.read(key: _kRefresh);
    if (r != null) {
      try {
        await api.logout(r);
      } catch (_) {}
    }
    _access = null;
    await storage.delete(key: _kRefresh);
  }

  /// Kiểm tra đăng nhập...
  Future<bool> isSignedIn() async =>
      (await storage.read(key: _kRefresh)) != null;


  Future<Map<String, dynamic>?>? _refreshing;

  Future<Map<String, dynamic>?> refreshIfPossible({String? deviceInfo}) {
    _refreshing ??= _refreshInternal(deviceInfo: deviceInfo);
    return _refreshing!.whenComplete(() => _refreshing = null);
  }

  Future<Map<String, dynamic>?> _refreshInternal({String? deviceInfo}) async {
    final r = await storage.read(key: _kRefresh);
    if (r == null) return null;
    try {
      final data = await api.refresh(r, deviceInfo: deviceInfo); // data chứa mọi thứ
      final newAccess = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;

      if (newAccess != null) _access = newAccess;
      if (newRefresh != null) {
        await storage.write(key: _kRefresh, value: newRefresh);
      }
      return data;
    } catch (_) {
      _access = null;
      await storage.delete(key: _kRefresh);
      return null;
    }
  }


  void setAccess(String? token) => _access = token;
}