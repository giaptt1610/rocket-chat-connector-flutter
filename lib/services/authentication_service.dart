import 'dart:convert';

import '../rocket_chat_connector.dart';

class AuthenticationService {
  HttpService _httpService;

  AuthenticationService(this._httpService);

  Future<Authentication> login(String user, String password) async {
    Map<String, String> body = {'user': user, 'password': password};
    final response = await _httpService.post(
      '/api/v1/login',
      jsonEncode(body),
    );

    if (response.success) {
      return Authentication.fromMap(response.data as Map<String, dynamic>);
    }

    return Authentication(status: 'error');
  }

  Future<User> me(Authentication authentication) async {
    final response = await _httpService.get(
      '/api/v1/me',
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return User.fromMap(response.data as Map<String, dynamic>);
    }
    return User();
  }
}
