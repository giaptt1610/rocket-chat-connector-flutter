import 'dart:convert';

import '../rocket_chat_connector.dart';

class ChannelService {
  HttpService _httpService;

  ChannelService(this._httpService);

  Future<ChannelNewResponse> create(
      ChannelNew channelNew, Authentication authentication) async {
    final response = await _httpService.post(
      '/api/v1/channels.create',
      jsonEncode(channelNew.toMap()),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return ChannelNewResponse.fromMap(response.data as Map<String, dynamic>);
    }
    return ChannelNewResponse();
  }

  Future<ChannelMessages> messages(
      Channel channel, Authentication authentication) async {
    final response = await _httpService.getWithFilter(
      '/api/v1/channels.messages',
      ChannelFilter(channel),
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return ChannelMessages.fromMap(response.data as Map<String, dynamic>);
    }

    return ChannelMessages();
  }

  Future<bool> markAsRead(
      Channel channel, Authentication authentication) async {
    Map<String, String?> body = {"rid": channel.id};

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

  Future<ChannelMessages> history(
      ChannelHistoryFilter filter, Authentication authentication) async {
    final response = await _httpService.getWithFilter(
      '/api/v1/channels.history',
      filter,
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return ChannelMessages.fromMap(response.data as Map<String, dynamic>);
    }

    return ChannelMessages();
  }

  Future<ChannelCounters> counters(
    ChannelCountersFilter filter,
    Authentication authentication,
  ) async {
    final response = await _httpService.getWithFilter(
      '/api/v1/channels.counters',
      filter,
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return ChannelCounters.fromMap(response.data as Map<String, dynamic>);
    }

    return ChannelCounters();
  }
}
