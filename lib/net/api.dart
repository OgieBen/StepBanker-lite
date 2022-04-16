import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  post(String endpointUrl, Map<String, Object?> payload) async {
    var url = Uri.parse(endpointUrl);
    final p = jsonEncode(payload);
    Fimber.d(p);
    var response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: p);
    return response;
  }

  fetch(String endpointUrl) async {
    return await http.get(Uri.parse(endpointUrl));
  }
}
