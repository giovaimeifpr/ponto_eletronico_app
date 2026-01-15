import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../core/errors/app_errors.dart';

class UserService {
  final UserRepository _repository = UserRepository();

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _repository.fetchAllUsers();

      return (response as List).map((u) => UserModel.fromJson(u)).toList();
    } catch (e) {
      throw AppErrors.handle(e);
    }
  }
}
