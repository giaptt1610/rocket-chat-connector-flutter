class ApiResponse {
  final bool success;
  final Object? data;
  final String errorMsg;

  ApiResponse({required this.success, this.data, this.errorMsg = ''});
}
