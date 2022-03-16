import 'package:flutter/material.dart';
import 'package:rocket_chat_connector_flutter/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String myUserName;
  final double maxWidth;
  const MessageBubble({
    required this.message,
    this.myUserName = '',
    this.maxWidth = 50.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine(myUserName);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isMine ? Colors.blue : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: isMine ? Colors.blue[200] : Colors.grey[300],
        ),
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment:
                  isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.user!.name}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4.0),
                Text(
                  '${message.updatedAt?.toLocal().toString() ?? ''}',
                  style: TextStyle(fontSize: 12.0),
                ),
              ],
            ),
            Text('${message.msg}'),
          ],
        ),
      ),
    );
  }
}
