import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../../features/auth/data/auth_repository.dart';

/// Dùng client này cho các API cần auth.
/// Nó sẽ gắn header Authorization nếu có access token
/// và khi gặp 401 sẽ tự refresh + retry đúng 1 lần.
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient(this._inner, this._repo, {required this.apiBase});
  final http.Client _inner;
  final AuthRepository _repo;
  final String apiBase;

  static bool _isAuthPath(Uri uri) {
    final p = uri.path;
    return p.contains('/auth/login') || p.contains('/auth/refresh') || p.contains('/auth/logout');
  }

  Future<String?> _deviceInfo() async {
    try {
      final info = await DeviceInfoPlugin().deviceInfo;
      return info.data['model']?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // gắn bearer nếu có
    final token = _repo.accessToken;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final first = await _inner.send(request);
    if (first.statusCode != 401 || _isAuthPath(request.url)) {
      return first;
    }

    // 401: thử refresh
    final dev = await _deviceInfo();
    final newAccess = await _repo.refreshIfPossible(deviceInfo: dev);
    if (newAccess == null) {
      return first; // fail: để UI xử lý (đẩy về login)
    }

    // retry 1 lần
    final replay = http.Request(request.method, request.url);
    replay.bodyBytes = await request.finalize().toBytes(); // copy body
    replay.headers.addAll(request.headers);
    replay.headers['Authorization'] = 'Bearer $newAccess';
    return _inner.send(replay);
  }
}
