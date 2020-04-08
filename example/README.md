#基于Android端的云闪付插件 实现支付功能

flutter需要向Android端传入云闪付所需的tn（订单流水）和mode（环境类型）
  Map<String, String> map = {"tn": "11111111", "mode": "01"};
调起云闪付方法
Android端在支付结束后将支付结果返回给flutter端
  String result = await jumpPlugin.invokeMethod('toPay', map);