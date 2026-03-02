abstract class AuthRepository {
  Future<bool> register(String email, String password);
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getCurrentUserEmail();
}
