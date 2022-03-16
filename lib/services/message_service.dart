import 'dart:convert';

import '../rocket_chat_connector.dart';

class MessageService {
  HttpService _httpService;

  MessageService(this._httpService);

  Future<MessageNewResponse> postMessage(
      MessageNew message, Authentication authentication) async {
    final response = await _httpService.post(
      '/api/v1/chat.postMessage',
      jsonEncode(message.toMap()),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return MessageNewResponse.fromMap(response.data as Map<String, dynamic>);
    }

    return MessageNewResponse();
  }
}
