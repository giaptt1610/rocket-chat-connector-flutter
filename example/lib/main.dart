import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rocket_chat_connector_flutter/rocket_chat_connector.dart'
    as rocket;

import 'message_bubble.dart';
import 'message_compose.dart';

void main() => runApp(MyApp());

final String serverUrl = "http://10.1.38.174:3000";
final String webSocketUrl = "ws://10.1.38.174:3000/websocket";
final String username = "giaptt";
final String password = "576173987";
final rocket.Channel channel = rocket.Channel(id: "myChannelId");
final rocket.Room room = rocket.Room(id: "9gKZbi7wi7H8zSdn3");
final rocket.HttpService rocketHttpService =
    rocket.HttpService(Uri.parse(serverUrl));

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
  rocket.WebSocketService webSocketService = rocket.WebSocketService();
  rocket.User? user;

  // ignore: close_sinks
  StreamController<List<rocket.Message>> messagesStream = StreamController();
  // ignore: close_sinks
  StreamController pingPongStream = StreamController();

  rocket.RoomService _roomService = rocket.RoomService(rocketHttpService);
  rocket.RoomMessages? roomMessages;
  rocket.Authentication? authData;
  List<rocket.Message> _messages = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<rocket.Authentication>(
        future: getAuthentication(),
        builder: (context, AsyncSnapshot<rocket.Authentication> snapshot) {
          if (snapshot.hasData) {
            authData = snapshot.data!;
            user = authData!.data!.me;
            final _authToken = authData!.data!.authToken!;
            webSocketChannel =
                webSocketService.connectToWebSocket(webSocketUrl, _authToken);

            webSocketService.streamNotifyUserSubscribe(
                webSocketChannel!, user!);

            webSocketService.loadHistory(webSocketChannel!, room);
            webSocketService.streamRoomMessagesSubscribe(
                webSocketChannel!, room);
            webSocketChannel!.stream.listen((event) {
              _handleServerEvent(event);
            });

            return _getScaffold(context);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Scaffold _getScaffold(BuildContext context) {
    final _maxWidth = MediaQuery.of(context).size.width * 0.8;
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
                    child: FutureBuilder<List<rocket.Room>>(
                      future: _roomService.getListRooms(authData!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
                        List<rocket.Room> rooms = snapshot.data ?? [];
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
                        final msgs = snapshot.data as List<rocket.Message>;

                        return ListView.separated(
                            reverse: true,
                            itemCount: msgs.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1),
                            itemBuilder: (context, index) => MessageBubble(
                                  maxWidth: _maxWidth,
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
      // webSocketService.sendMessageOnChannel(
      //     _controller.text, webSocketChannel!, channel);
      webSocketService.sendMessageOnRoom(
          _controller.text, webSocketChannel!, room);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    webSocketService.streamRoomMessagesUnsubscribe(webSocketChannel!, room);
    webSocketChannel?.sink.close();
    messagesStream.sink.close();
    pingPongStream.sink.close();
    super.dispose();
  }

  Future<rocket.Authentication> getAuthentication() async {
    final rocket.AuthenticationService authenticationService =
        rocket.AuthenticationService(rocketHttpService);
    return await authenticationService.login(username, password);
  }

  void _handleServerEvent(String event) {
    try {
      final json = jsonDecode(event) as Map<String, dynamic>;
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
      } else if (_msg == 'changed' &&
          json['collection'] == 'stream-room-messages') {
        handleStreamRoomMessage(json);
      }
    } catch (e) {
      print('${e.toString()}');
    }
  }

  void handleMessageStream(List listMessage) {
    try {
      final list = listMessage.map((e) => rocket.Message.fromMap(e)).toList();
      _messages.insertAll(0, [...list]);
      messagesStream.sink.add(_messages);
    } catch (e) {
      messagesStream.sink.addError(e);
    }
  }

  void handleStreamRoomMessage(Map<String, dynamic> json) {
    rocket.Notification notification = rocket.Notification.fromMap(json);
    final fields = notification.fields;
    final args = fields?.args ?? [];
    final msgs = args
        .map((e) => rocket.Message(id: e.id, msg: e.msg, user: e.user))
        .toList();
    _messages.insertAll(0, [...msgs]);
    messagesStream.sink.add(_messages);
  }
}
