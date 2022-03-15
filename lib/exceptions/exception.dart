class RocketChatException implements Exception {
  String message;
  RocketChatException(this.message);

  String toString() {
    return "RocketChatException: $message";
  }
}
