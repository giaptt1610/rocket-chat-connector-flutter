import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rocket_chat_connector_flutter/rocket_chat_connector.dart'
    as rocket;

import 'chat_page.dart';
import 'constants.dart';

class HomePage extends StatefulWidget {
  final rocket.Authentication authData;
  HomePage({required this.authData, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final webSocketService = rocket.WebSocketService(webSocketUrl);
  rocket.User? user;

  final _rocketHttpService = rocket.HttpService(Uri.parse(serverUrl));
  late rocket.RoomService _roomService;
  rocket.RoomMessages? roomMessages;
  rocket.Authentication? authData;

  @override
  void initState() {
    super.initState();
    user = widget.authData.data!.me;
    _roomService = rocket.RoomService(_rocketHttpService);
    webSocketService.connectToWebSocket(widget.authData.data!.authToken);

    webSocketService.stream.listen((event) {
      _handleServerEvent(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                height: 60,
                child: FutureBuilder<List<rocket.Room>>(
                  future: _roomService.getListRooms(widget.authData),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CupertinoActivityIndicator();
                    }

                    List<rocket.Room> list = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: list.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: InkWell(
                            child: Center(
                              child: Text(list[index].getRoomName(
                                  widget.authData.data!.me.username!)),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ChatPage(
                                          room: list[index],
                                          wsService: webSocketService,
                                          user: user!,
                                        )),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleServerEvent(String event) {
    try {
      final json = jsonDecode(event) as Map<String, dynamic>;
      final _msg = json['msg'];
      print('home_page: $json');
      if (_msg == 'ping') {
        webSocketService.sendPongMsg();
      }
    } catch (e) {
      print('${e.toString()}');
    }
  }

  @override
  void dispose() {
    webSocketService.dispose();
    super.dispose();
  }
}
