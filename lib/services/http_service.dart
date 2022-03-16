import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/filters/filter.dart';
import '../models/response/api_response.dart';

class HttpService {
  Uri? _apiUrl;

  HttpService(Uri apiUrl) {
    _apiUrl = apiUrl;
  }

  Future<ApiResponse> getWithFilter(
    String uri,
    Filter filter, {
    String? authToken,
    String? userId,
  }) async {
    final _uri = uri + '?' + _urlEncode(filter.toMap());
    return get(_uri, authToken: authToken, userId: userId);
  }

  Future<ApiResponse> get(
    String uri, {
    String? authToken,
    String? userId,
  }) async {
    try {
      final response = await http.get(Uri.parse(_apiUrl.toString() + uri),
          headers: _getHeaders(authToken: authToken, userId: userId));
      if (response.statusCode != 200) {
        return ApiResponse(success: false, errorMsg: response.body);
      }
      final json = jsonDecode(response.body);
      return ApiResponse(success: true, data: json);
    } catch (e) {
      print('Exception: ${e.toString()}');
      return ApiResponse(success: false, errorMsg: e.toString());
    }
  }

  Future<ApiResponse> post(
    String uri,
    String body, {
    String? authToken,
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl.toString() + uri),
        headers: _getHeaders(authToken: authToken, userId: userId),
        body: body,
      );
      if (response.statusCode != 200) {
        return ApiResponse(success: false, errorMsg: response.body);
      }
      final json = jsonDecode(response.body);
      return ApiResponse(success: true, data: json);
    } catch (e) {
      return ApiResponse(success: false, errorMsg: e.toString());
    }
  }

  Future<http.Response> put(
    String uri,
    String body, {
    String? authToken,
    String? userId,
  }) async =>
      await http.put(
        Uri.parse(_apiUrl.toString() + uri),
        body: body,
        headers: _getHeaders(authToken: authToken, userId: userId),
      );

  Future<http.Response> delete(
    String uri, {
    String? authToken,
    String? userId,
  }) async =>
      await http.delete(
        Uri.parse(_apiUrl.toString() + uri),
        headers: _getHeaders(authToken: authToken, userId: userId),
      );

  Map<String, String> _getHeaders({String? authToken, String? userId}) {
    Map<String, String> header = {
      'Content-type': 'application/json',
    };

    if (authToken != null) {
      header['X-Auth-Token'] = authToken;
    }

    if (userId != null) {
      header['X-User-Id'] = userId;
    }

    return header;
  }
}

String _urlEncode(Map object) {
  int index = 0;
  String url = object.keys.map((key) {
    if (object[key]?.toString().isNotEmpty == true) {
      String value = "";
      if (index != 0) {
        value = "&";
      }
      index++;
      return "$value${Uri.encodeComponent(key)}=${Uri.encodeComponent(object[key].toString())}";
    }
    return "";
  }).join();
  return url;
}
