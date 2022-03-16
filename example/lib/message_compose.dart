import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageCompose extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;
  const MessageCompose({this.controller, this.onSend, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Send a message'),
            ),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                CupertinoIcons.chat_bubble,
                color: Colors.green,
              ),
            ),
            onTap: onSend,
          ),
        ],
      ),
    );
  }
}
