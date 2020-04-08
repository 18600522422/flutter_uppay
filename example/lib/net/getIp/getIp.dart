import 'dart:convert';

import 'package:dio/dio.dart';

class getIP{
  static const _IPApiUrl = "https://httpbin.org/ip";
  final JsonDecoder _decoder = new JsonDecoder();
  Future<String> getIp() async {
    Dio dio = new Dio();
    Response response=await dio.get(_IPApiUrl);
    return response.data["origin"].toString().split(",")[0];

  }
}