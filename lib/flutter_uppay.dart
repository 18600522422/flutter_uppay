import 'dart:async';

import 'package:flutter/services.dart';

class FlutterUppay {
  static const MethodChannel _channel =
      const MethodChannel('flutter_uppay');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
