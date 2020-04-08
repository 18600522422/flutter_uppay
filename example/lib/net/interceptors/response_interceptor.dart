import 'dart:convert';

import 'package:dio/dio.dart';
import '../code.dart';
import '../result_data.dart';

/**
 * Token拦截器
 * Created by guoshuyu
 * on 2019/3/23.
 */
class ResponseInterceptors extends InterceptorsWrapper {
  @override
  onResponse(Response response) {
    RequestOptions option = response.request;
    try {
      if (option.contentType != null &&
          option.contentType.primaryType == "text") {
        return new ResultData(response.data, true, Code.SUCCESS);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
/*       Map data = json.decode(response.data.toString());
        print(data["d"]["ErrorCode"]);
         if(data["d"]["ErrorCode"]==null ){*/
          return new ResultData(response.data, true, Code.SUCCESS,
              headers: response.headers);
/*        }else{
          return new ResultData(Code.errorHandleFunction(6666, data["d"]["Msg"], false), false, 6666);
        }*/

      }
    } catch (e) {
      print("错误：" + e.toString() + option.path);
      return new ResultData(response.data, false, response.statusCode,
          headers: response.headers);
    }
  }
}
