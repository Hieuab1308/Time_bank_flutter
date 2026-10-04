
abstract class IAuthApi {
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    String? deviceInfo,
  });

  Future<Map<String, dynamic>> refresh(
      String refreshToken, {
        String? deviceInfo,
      });

  Future<void> logout(String refreshToken);
}
