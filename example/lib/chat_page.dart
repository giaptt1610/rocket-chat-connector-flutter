import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rocket_chat_connector_flutter/rocket_chat_connector.dart'
    as rocket;
import 'package:rocket_chat_connector_flutter/models/room.dart';

import 'message_bubble.dart';
import 'message_compose.dart';

class ChatPage extends StatefulWidget {
  final Room room;
  final rocket.WebSocketService wsService;
  final rocket.User user;

  ChatPage({
    required this.room,
    required this.wsService,
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ignore: close_sinks
  StreamController<List<rocket.Message>> messagesStream = StreamController();
  TextEditingController _controller = TextEditingController();
  late rocket.WebSocketService _ws;

  List<rocket.Message> _messages = [];
  @override
  void initState() {
    super.initState();
    _ws = widget.wsService;

    _ws.stream.listen((event) {
      _handleServerEvent(event);
    });
    // _ws.streamNotifyUserSubscribe(user!);
    _ws.loadHistory(widget.room);
    _ws.streamRoomMessagesSubscribe(widget.room);
  }

  @override
  Widget build(BuildContext context) {
    final _maxWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              myUserName: widget.user.username!,
                            ),
                          );
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
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _ws.sendMessageOnRoom(_controller.text, widget.room);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ws.streamRoomMessagesUnsubscribe(widget.room);
    super.dispose();
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
