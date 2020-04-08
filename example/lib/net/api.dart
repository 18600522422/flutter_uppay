import 'dart:convert';

import 'package:dio/dio.dart';

// import 'interceptors/check_interceptor.dart';
import 'interceptors/header_interceptor.dart';
import 'result_data.dart';
import 'dart:collection';
import 'code.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/response_interceptor.dart';

///http请求
class HttpManager {
  static const loading = "数据加载中...";
  Dio _dio = new Dio(); // 使用默认配置

  HttpManager() {
    _dio.interceptors.add(new HeaderInterceptors());

    /* _dio.interceptors.add(new LogsInterceptors());*/

    _dio.interceptors.add(new ErrorInterceptors(_dio));

    _dio.interceptors.add(new ResponseInterceptors());
  }

  ///发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置
  netFetch(url, params, Map<String, dynamic> header, Options option,
      {noTip = false}) async {
    //抓包工具 需设置代理才能抓取数据
  //  (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
  //    //设置代理
  //    client.findProxy = (uri) {
  //      return "PROXY 172.24.113.1:8888";
  //    };
  //  };
    // print("url=====$url");
    // print("params=====${params.toString()}");
    Map<String, dynamic> headers = new HashMap();
    if (header != null) {
      headers.addAll(header);
    }
    if (option != null) {
      option.headers = headers;
    } else {
      option = new Options(method: "post");
      option.headers = headers;
      option.responseType = ResponseType.plain;
    }

    Response response;
    try {
      response = await _dio.request(url, data: params, options: option);
    } on DioError catch (e) {
      Response errorResponse;
      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      if (e.type == DioErrorType.CONNECT_TIMEOUT ||
          e.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorResponse.statusCode = Code.NETWORK_TIMEOUT;
      }
      return new ResultData(
          Code.errorHandleFunction(errorResponse.statusCode, e.message, noTip),
          false,
          errorResponse.statusCode);
    }

    return response.data;
  }
}

final HttpManager httpManager = new HttpManager();
