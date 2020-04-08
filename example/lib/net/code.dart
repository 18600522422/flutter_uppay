import 'package:event_bus/event_bus.dart';
///错误编码
class Code {
  ///网络错误
  static const NETWORK_ERROR = -1;

  ///网络超时
  static const NETWORK_TIMEOUT = -2;

  ///网络返回数据格式化一次
  static const NETWORK_JSON_EXCEPTION = -3;

  static const SUCCESS = 200;

  static final EventBus eventBus = new EventBus();

  static errorHandleFunction(code, message, noTip) {
    eventBus.fire(new HttpErrorEvent(code, message));
  }
}

class HttpErrorEvent {
  final int code;
  final String message;
  HttpErrorEvent(this.code, this.message);
}
class UserLoggedInEvent {
  final int code;
  UserLoggedInEvent(this.code);
}
class PayCodeStatus{
  final String Paycode;
  PayCodeStatus(this.Paycode);
}