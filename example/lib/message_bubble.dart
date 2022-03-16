import 'package:flutter/material.dart';
import 'package:rocket_chat_connector_flutter/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String myUserName;
  const MessageBubble({required this.message, this.myUserName = '', Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine(myUserName);
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isMine ? Colors.blue : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: isMine ? Colors.blue[200] : Colors.grey[300],
        ),
        padding: const EdgeInsets.all(6.0),
        child: Text('${message.msg}'),
      ),
    );
  }
}
