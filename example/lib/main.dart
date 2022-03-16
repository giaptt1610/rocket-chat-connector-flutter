import 'dart:async';
import 'dart:convert';

import 'package:example/message_bubble.dart';
import 'package:example/message_compose.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rocket_chat_connector_flutter/models/authentication.dart';
import 'package:rocket_chat_connector_flutter/models/channel.dart';
import 'package:rocket_chat_connector_flutter/models/filters/room_history_filter.dart';
import 'package:rocket_chat_connector_flutter/models/message.dart';
import 'package:rocket_chat_connector_flutter/models/room.dart';
import 'package:rocket_chat_connector_flutter/models/room_messages.dart';
import 'package:rocket_chat_connector_flutter/models/user.dart';
import 'package:rocket_chat_connector_flutter/services/authentication_service.dart';
import 'package:rocket_chat_connector_flutter/services/http_service.dart'
    as rocket_http_service;
import 'package:rocket_chat_connector_flutter/services/room_service.dart';
import 'package:rocket_chat_connector_flutter/web_socket/notification.dart'
    as rocket_notification;
import 'package:rocket_chat_connector_flutter/web_socket/web_socket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

final String serverUrl = "http://10.1.38.174:3000";
final String webSocketUrl = "ws://10.1.38.174:3000/websocket";
final String username = "giaptt";
final String password = "576173987";
final Channel channel = Channel(id: "myChannelId");
final Room room = Room(id: "9gKZbi7wi7H8zSdn3");
final rocket_http_service.HttpService rocketHttpService =
    rocket_http_service.HttpService(Uri.parse(serverUrl));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Rocket Chat';

    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  WebSocketChannel? webSocketChannel;
  WebSocketService webSocketService = WebSocketService();
  User? user;

  StreamController<List<Message>> messagesStream = StreamController();
  StreamController pingPongStream = StreamController();

  RoomService _roomService = RoomService(rocketHttpService);
  RoomMessages? roomMessages;
  Authentication? authData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Authentication>(
        future: getAuthentication(),
        builder: (context, AsyncSnapshot<Authentication> snapshot) {
          if (snapshot.hasData) {
            authData = snapshot.data!;
            user = authData!.data!.me;
            final _authToken = authData!.data!.authToken!;
            webSocketChannel =
                webSocketService.connectToWebSocket(webSocketUrl, _authToken);

            webSocketService.streamNotifyUserSubscribe(
                webSocketChannel!, user!);

            webSocketService.loadHistory(webSocketChannel!, room);
            webSocketChannel!.stream.listen((event) {
              _handleServerEvent(event);
            });

            return _getScaffold();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Scaffold _getScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    child: FutureBuilder<List<Room>>(
                      future: _roomService.getListRooms(authData!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
                        List<Room> rooms = snapshot.data ?? [];
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 80,
                              child: Text(rooms[index].name ??
                                  rooms[index]
                                      .getRecipentUser(user!.username!)),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 20,
                    child: StreamBuilder(
                      stream: pingPongStream.stream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        return Text('${snapshot.data.toString()}');
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: messagesStream.stream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }

                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        final msgs = snapshot.data as List<Message>;

                        return ListView.separated(
                            reverse: true,
                            itemCount: msgs.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1),
                            itemBuilder: (context, index) => MessageBubble(
                                  message: msgs[index],
                                  myUserName: user!.username!,
                                ));
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MessageCompose(
                controller: _controller,
                onSend: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      webSocketService.sendMessageOnChannel(
          _controller.text, webSocketChannel!, channel);
      webSocketService.sendMessageOnRoom(
          _controller.text, webSocketChannel!, room);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    webSocketChannel?.sink.close();
    messagesStream.sink.close();
    pingPongStream.sink.close();
    super.dispose();
  }

  Future<Authentication> getAuthentication() async {
    final AuthenticationService authenticationService =
        AuthenticationService(rocketHttpService);
    return await authenticationService.login(username, password);
  }

  void _handleServerEvent(String event) {
    try {
      final json = jsonDecode(event) as Map;
      final _msg = json['msg'];
      print(json);
      if (_msg == 'result') {
        final result = json['result'] as Map;
        final message = result['messages'];
        if (message != null && message is List) {
          handleMessageStream(message);
        }
      } else if (_msg == 'ping') {
        webSocketService.sendPongMsg(webSocketChannel!);
        pingPongStream.sink.add(event);
      } else if (_msg == 'changed') {}
    } catch (e) {
      print('${e.toString()}');
    }
  }

  void handleMessageStream(List listMessage) {
    try {
      List<Message> list = listMessage.map((e) => Message.fromMap(e)).toList();
      messagesStream.sink.add(list);
    } catch (e) {
      messagesStream.sink.addError(e);
    }
  }
}
