import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rocket_chat_connector_flutter/exceptions/exception.dart';
import 'package:rocket_chat_connector_flutter/models/authentication.dart';
import 'package:rocket_chat_connector_flutter/models/filters/room_counters_filter.dart';
import 'package:rocket_chat_connector_flutter/models/filters/room_filter.dart';
import 'package:rocket_chat_connector_flutter/models/filters/room_history_filter.dart';
import 'package:rocket_chat_connector_flutter/models/new/room_new.dart';
import 'package:rocket_chat_connector_flutter/models/response/response.dart';
import 'package:rocket_chat_connector_flutter/models/response/room_new_response.dart';
import 'package:rocket_chat_connector_flutter/models/room.dart';
import 'package:rocket_chat_connector_flutter/models/room_counters.dart';
import 'package:rocket_chat_connector_flutter/models/room_messages.dart';
import 'package:rocket_chat_connector_flutter/services/http_service.dart';

class RoomService {
  HttpService _httpService;

  RoomService(this._httpService);

  Future<RoomNewResponse> create(
    RoomNew roomNew,
    Authentication authentication,
  ) async {
    http.Response response = await _httpService.post(
      '/api/v1/im.create',
      jsonEncode(roomNew.toMap()),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return RoomNewResponse.fromMap(jsonDecode(response.body));
      } else {
        return RoomNewResponse();
      }
    }
    throw RocketChatException(response.body);
  }

  Future<RoomMessages> messages(
      Room room, Authentication authentication) async {
    final response = await _httpService.getWithFilter(
      '/api/v1/im.messages',
      RoomFilter(room),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return RoomMessages.fromMap(response.data as Map<String, dynamic>);
    }

    return RoomMessages();
    // if (response.statusCode == 200) {
    //   if (response.body.isNotEmpty == true) {
    //     return RoomMessages.fromMap(jsonDecode(response.body));
    //   } else {
    //     return RoomMessages();
    //   }
    // }
    // throw RocketChatException(response.body);
  }

  Future<bool> markAsRead(Room room, Authentication authentication) async {
    Map<String, String?> body = {"rid": room.id};

    http.Response response = await _httpService.post(
      '/api/v1/subscriptions.read',
      jsonEncode(body),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return Response.fromMap(jsonDecode(response.body)).success == true;
      } else {
        return false;
      }
    }
    throw RocketChatException(response.body);
  }

  Future<RoomMessages> history(
      RoomHistoryFilter filter, Authentication authentication) async {
    final response = await _httpService.getWithFilter(
      '/api/v1/im.history',
      filter,
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return RoomMessages.fromMap(response.data as Map<String, dynamic>);
    }

    return RoomMessages();
    // if (response.statusCode == 200) {
    //   if (response.body.isNotEmpty == true) {
    //     return RoomMessages.fromMap(jsonDecode(response.body));
    //   } else {
    //     return RoomMessages();
    //   }
    // }
    // throw RocketChatException(response.body);
  }

  Future<RoomCounters> counters(
      RoomCountersFilter filter, Authentication authentication) async {
    final response = await _httpService.getWithFilter(
      '/api/v1/im.counters',
      filter,
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return RoomCounters.fromMap(response.data as Map<String, dynamic>);
    }

    return RoomCounters();
    // if (response.statusCode == 200) {
    //   if (response.body.isNotEmpty == true) {
    //     return RoomCounters.fromMap(jsonDecode(response.body));
    //   } else {
    //     return RoomCounters();
    //   }
    // }
    // throw RocketChatException(response.body);
  }

  Future<List<Room>> getListRooms(Authentication authentication) async {
    final response = await _httpService.get(
      '/api/v1/rooms.get',
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      final list = (response.data as Map<String, dynamic>)['update'] as List;
      return list.map((e) => Room.fromMap(e)).toList();
    }

    return [];
  }
}
