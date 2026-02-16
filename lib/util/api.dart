import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mpluslicense/util/returnmessages.dart';

class API {
  Future getAuthorization_(String url_, Map bodydata) async {
    Uri url = Uri.parse(url_);
    var body = json.encode(bodydata);
    var headers = {"Content-Type": "application/json"};
    var request = http.Request('POST', url);
    request.body = body;
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    return response;
  }

  Future<http.StreamedResponse> request_(BuildContext context, String method,
      String url_, Map bodyData, String token) async {
    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    var body_ = json.encode(bodyData);
    var request = http.Request(method, Uri.parse(url_));
    request.body = body_;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 401) {
      await SessionManager().destroy();
      if (context.mounted) Navigator.pushNamed(context, '/login');
    } else if (response.statusCode == 403) {
      if (context.mounted) {
        ReturnMessages().showSnackBar(
            context, 'Bu əməliyyat üçün səlahiyyətiniz yoxdur!', 0);
      }
    } else if (response.statusCode == 409) {
      String errorMessage = await response.stream.bytesToString();
      if (context.mounted) {
        ReturnMessages().showSnackBar(context, errorMessage, 0);
      }
    } else if (response.statusCode != 200) {
      if (context.mounted) {
        String errorMessage = await response.stream.bytesToString();
        if (!context.mounted) return response;
        ReturnMessages().showSnackBar(context, 'Xəta:$errorMessage', 0);
      }
    }
    return response;
  }
}
