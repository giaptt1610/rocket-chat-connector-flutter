import 'package:collection/collection.dart';

class Room {
  String? id;
  DateTime? updatedAt;
  String? t;
  int? msgs;
  DateTime? ts;
  DateTime? lm;
  String? topic;
  String? rid;
  List<String>? usernames;
  String? fname;
  String? name;

  Room({
    this.id,
    this.updatedAt,
    this.t,
    this.msgs,
    this.ts,
    this.lm,
    this.topic,
    this.rid,
    this.usernames,
    this.fname,
    this.name,
  });

  Room.fromMap(Map<String, dynamic> json) {
    id = json['_id'];
    rid = json['rid'];
    updatedAt = DateTime.tryParse(json['_updatedAt']);
    t = json['t'];
    msgs = json['msgs'];
    ts = DateTime.tryParse(json['ts']);
    lm = DateTime.tryParse(json['lm']);
    topic = json['topic'];
    usernames =
        json['usernames'] != null ? List<String>.from(json['usernames']) : null;
    fname = json['fname'];
    name = json['name'];
  }

  String getRoomName(String me) {
    if (t == 'd') {
      final users = usernames ?? [];
      return users.firstWhere((element) => element != me,
          orElse: () => 'unknown');
    } else if (t == 'c') {
      return id!;
    } else if (t == 'p') {
      return fname!;
    }

    return 'unknown';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (id != null) {
      map['_id'] = id;
    }
    if (rid != null) {
      map['rid'] = rid;
    }
    if (updatedAt != null) {
      map['_updatedAt'] = updatedAt!.toIso8601String();
    }
    if (t != null) {
      map['t'] = t;
    }
    if (msgs != null) {
      map['msgs'] = msgs;
    }
    if (ts != null) {
      map['ts'] = ts!.toIso8601String();
    }
    if (lm != null) {
      map['lm'] = lm!.toIso8601String();
    }

    if (topic != null) {
      map['topic'] = topic;
    }

    return map;
  }

  @override
  String toString() {
    return 'Room{id: $id, updatedAt: $updatedAt, t: $t, msgs: $msgs, ts: $ts, lm: $lm, topic: $topic, rid: $rid, usernames: $usernames}';
  }

  String getRecipentUser(String me) {
    if (t == 'd') {
      final users = usernames ?? [];
      return users.firstWhere((element) => element != me, orElse: () => '');
    }

    return '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          updatedAt == other.updatedAt &&
          t == other.t &&
          msgs == other.msgs &&
          ts == other.ts &&
          lm == other.lm &&
          topic == other.topic &&
          rid == other.rid &&
          DeepCollectionEquality().equals(usernames, other.usernames);

  @override
  int get hashCode =>
      id.hashCode ^
      updatedAt.hashCode ^
      t.hashCode ^
      msgs.hashCode ^
      ts.hashCode ^
      lm.hashCode ^
      topic.hashCode ^
      rid.hashCode ^
      usernames.hashCode;
}
