import 'dart:convert';

import '../models/authentication.dart';
import '../models/new/user_new.dart';
import '../models/user.dart';
import 'http_service.dart';

class UserService {
  HttpService _httpService;

  UserService(this._httpService);

  Future<User> create(UserNew userNew, Authentication authentication) async {
    final response = await _httpService.post(
      '/api/v1/users.create',
      jsonEncode(userNew.toMap()),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return User.fromMap(response.data as Map<String, dynamic>);
    }

    return User();
  }
}
