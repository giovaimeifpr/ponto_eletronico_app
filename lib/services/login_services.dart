import '../models/user_model.dart';
import '../repositories/login_repository.dart'; 
import '../core/errors/app_errors.dart';

class LoginService {
  final LoginRepository _repository = LoginRepository();

  Future<UserModel> getUserData(String email) async {
    try {
      final data = await _repository.fetchRawUserData(email);
      return UserModel.fromJson(data);
    } catch (e) {
      // Não precisamos de múltiplos catchs se o AppErrors.handle já resolve tudo
      throw AppErrors.handle(e);
    }
  }

  Future<bool> login(String email) async {
    try {
      final user = await _repository.checkUserExists(email);
      return user != null;
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }
}