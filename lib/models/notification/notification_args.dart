import '../user.dart';
import 'notification_payload.dart';

class NotificationArgs {
  String? title;
  String? text;
  DateTime? ts;
  NotificationPayload? payload;
  String? id;
  String? rid;
  String? msg;
  User? user;
  DateTime? updatedAt;

  NotificationArgs({
    this.title,
    this.text,
    this.payload,
  });

  NotificationArgs.fromMap(Map<String, dynamic> json) {
    title = json['title'];
    text = json['text'];
    ts = DateTime.now();
    id = json['_id'];
    rid = json['rid'];
    msg = json['msg'];
    user = json['u'] != null ? User.fromMap(json['u']) : null;
    if (json['_updatedAt']['\$date'] != null) {
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(json['_updatedAt']['\$date']);
    }

    payload = json['payload'] != null
        ? NotificationPayload.fromMap(json['payload'])
        : null;
  }

  @override
  String toString() {
    return 'NotificationArgs{title: $title, text: $text, ts: $ts, payload: $payload, msg: $msg}';
  }
}
