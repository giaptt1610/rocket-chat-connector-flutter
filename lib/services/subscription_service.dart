import '../rocket_chat_connector.dart';

class SubscriptionService {
  HttpService _httpService;

  SubscriptionService(this._httpService);

  Future<Subscription> getSubscriptions(Authentication authentication) async {
    final response = await _httpService.get(
      '/api/v1/subscriptions.get',
      authToken: authentication.data?.authToken,
      userId: authentication.data?.userId,
    );

    if (response.success) {
      return Subscription.fromMap(response.data as Map<String, dynamic>);
    }

    return Subscription();
  }
}
