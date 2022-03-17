import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../rocket_chat_connector.dart';

class WebSocketService {
  final WebSocketChannel _channel;
  late Stream _broadcastStream;

  WebSocketService(String url) : _channel = IOWebSocketChannel.connect(url) {
    _broadcastStream = _channel.stream.asBroadcastStream();
  }

  Stream get stream => _broadcastStream;

  void dispose() {
    _channel.sink.close();
  }

  WebSocketChannel connectToWebSocket(String authToken) {
    _sendConnectRequest();
    _sendLoginRequest(authToken);
    return _channel;
  }

  void _sendConnectRequest() {
    _channel.sink.add(jsonEncode({
      "msg": "connect",
      "version": "1",
      "support": ["1", "pre2", "pre1"]
    }));
  }

  void _sendLoginRequest(String authToken) {
    _channel.sink.add(jsonEncode({
      "msg": "method",
      "method": "login",
      "id": "42",
      "params": [
        {"resume": authToken}
      ]
    }));
  }

  void streamNotifyUserSubscribe(User user) {
    Map msg = {
      "msg": "sub",
      "id": user.id! + "subscription-id",
      "name": "stream-notify-user",
      "params": [user.id! + "/notification", false]
    };

    _channel.sink.add(jsonEncode(msg));
  }

  void streamChannelMessagesSubscribe(Channel channel) {
    Map msg = {
      "msg": "sub",
      "id": channel.id! + "subscription-id",
      "name": "stream-room-messages",
      "params": [channel.id, false]
    };
    _channel.sink.add(jsonEncode(msg));
  }

  void streamChannelMessagesUnsubscribe(Channel channel) {
    Map msg = {
      "msg": "unsub",
      "id": channel.id! + "subscription-id",
    };
    _channel.sink.add(jsonEncode(msg));
  }

  void streamRoomMessagesSubscribe(Room room) {
    Map msg = {
      "msg": "sub",
      "id": room.id! + "subscription-id",
      "name": "stream-room-messages",
      "params": [room.id, false]
    };
    _channel.sink.add(jsonEncode(msg));
  }

  void streamRoomMessagesUnsubscribe(Room room) {
    Map msg = {
      "msg": "unsub",
      "id": room.id! + "subscription-id",
    };
    _channel.sink.add(jsonEncode(msg));
  }

  void sendMessageOnChannel(String message, Channel channel) {
    Map msg = {
      "msg": "method",
      "method": "sendMessage",
      "id": "42",
      "params": [
        {"rid": channel.id, "msg": message}
      ]
    };

    _channel.sink.add(jsonEncode(msg));
  }

  void sendMessageOnRoom(String message, Room room) {
    Map msg = {
      "msg": "method",
      "method": "sendMessage",
      "id": "42",
      "params": [
        {"rid": room.id, "msg": message}
      ]
    };

    _channel.sink.add(jsonEncode(msg));
  }

  void sendUserPresence() {
    Map msg = {
      "msg": "method",
      "method": "UserPresence:setDefaultStatus",
      "id": "42",
      "params": ["online"]
    };
    _channel.sink.add(jsonEncode(msg));
  }

  void sendPongMsg() {
    _channel.sink.add(jsonEncode({'msg': 'pong'}));
  }

  void loadHistory(
    Room room, {
    int limit = 50,
  }) {
    Map msg = {
      "msg": "method",
      "method": "loadHistory",
      "id": "42",
      "params": [
        room.id,
        null,
        limit,
        {"\$date": 1480377601}
      ]
    };
    _channel.sink.add(jsonEncode(msg));
  }
}
