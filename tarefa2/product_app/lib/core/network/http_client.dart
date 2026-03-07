import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  Future<HttpResponse> get(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return HttpResponse(
        data: jsonDecode(response.body),
        statusCode: response.statusCode,
      );
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class HttpResponse {
  final dynamic data;
  final int statusCode;

  HttpResponse({
    required this.data,
    required this.statusCode,
  });
}
