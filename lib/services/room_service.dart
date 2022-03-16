import 'dart:convert';

import '../rocket_chat_connector.dart';

class RoomService {
  HttpService _httpService;

  RoomService(this._httpService);

  Future<RoomNewResponse> create(
    RoomNew roomNew,
    Authentication authentication,
  ) async {
    final response = await _httpService.post(
      '/api/v1/im.create',
      jsonEncode(roomNew.toMap()),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return RoomNewResponse.fromMap(response.data as Map<String, dynamic>);
    }

    return RoomNewResponse();
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
  }

  Future<bool> markAsRead(Room room, Authentication authentication) async {
    Map<String, String?> body = {"rid": room.id};

    final response = await _httpService.post(
      '/api/v1/subscriptions.read',
      jsonEncode(body),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return Response.fromMap(response.data as Map<String, dynamic>).success ??
          false;
    }
    return false;
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
