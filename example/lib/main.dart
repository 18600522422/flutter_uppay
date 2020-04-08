import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_uppay_example/net/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const jumpPlugin = const MethodChannel('flutter_uppay');
  TextEditingController _nameController = TextEditingController();

  ///订单编号
  String orderNo;

  ///支付状态
  String patStates;

  ///订单金额
  String orderAmount;

  ///退货金额
  String refundAmount;

  ///订单时间
  String payTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      decoration: new InputDecoration(
                        hintText: "请输入消费金额",
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Color(0XFF2d2d2d),
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _createOrder();
                    },
                    child: Text('调起云闪付'),
                  )
                ],
              ),
              RaisedButton(
                onPressed: () {
                  _orderSearch();
                },
                child: Text('手动获取支付状态'),
              ),
              Text(ifDefine(patStates) ? patStates : ""),
              RaisedButton(
                onPressed: () {
                  _consumeUndo();
                },
                child: Text('撤销'),
              ),
              RaisedButton(
                onPressed: () {
                  _orderRefund();
                },
                child: Text('退货'),
              )
            ],
          )),
    );
  }

  ///创建订单编号
  Future<Null> _createOrder() async {
    if (!ifDefine(_nameController.text)) {
      showToast('请输入消费金额');
      return;
    }
    var res = await getrequest(
        "http://192.168.6.78:8055/api/Pay/CreateOrder",
        {
          "merId": "777290058168478",
          "orderAmount": _nameController.text.toString().trim(),
        },
        null,
        null,
        showDlog: true);
    var d = json.decode(res.data);
    if (d["Code"] != 0) {
      showToast(d["Msg"]);
      return;
    } else {
      orderNo = d["Result"]["orderNo"];
      _getPayTn(orderNo);
    }
  }

  ///支付获取tn
  Future<Null> _getPayTn(String orderNo) async {
    if (!ifDefine(orderNo)) {
      showToast('创建订单失败');
      return;
    }
    var res = await getrequest(
        "http://192.168.6.78:8055/api/Pay/GetPayTn",
        {
          "merId": "777290058168478",
          "orderNo": orderNo,
        },
        null,
        null,
        showDlog: true);
    var d = json.decode(res.data);
    if (d["Code"] != 0) {
      showToast(d["Msg"]);
      return;
    } else {
      print("tn---------------------" + d["Result"]["tn"]);
      Map<String, String> map = {"tn": d["Result"]["tn"], "mode": "01"};

      String result = await jumpPlugin.invokeMethod('toPay', map);

      print("flutter接收到-----" + result);
    }
  }

  ///3.3.订单查询
  Future<Null> _orderSearch() async {
    if (!ifDefine(orderNo)) {
      showToast('暂无订单可查');
      return;
    }
    var res = await getrequest(
        "http://192.168.6.78:8055/api/Pay/OrderSearch",
        {
          "merId": "777290058168478",
          "orderNo": orderNo,
        },
        null,
        null,
        showDlog: true);
    if (!ifDefine(res.data)) {
      showToast("服务器异常");
      return;
    }
    var d = json.decode(res.data);
    if (d["Code"] != 0) {
      showToast(d["Msg"]);
      return;
    } else {
      orderAmount = d["Result"]["orderAmount"].toString();
      refundAmount = d["Result"]["refundAmount"].toString();
      if (ifDefine(d["Result"]["payTime"])) {
        payTime = d["Result"]["payTime"];
      } else {
        payTime = "";
      }
      setState(() {
        patStates = "订单状态：" +
            d["Result"]["orderStatus"] +
            "\n订单编号" +
            d["Result"]["orderNo"] +
            "\n订单金额" +
            orderAmount +
            "\n支付时间" +
            payTime +
            "\n退款金额" +
            refundAmount;
      });
    }
  }

  ///3.4.消费撤销
  Future<Null> _consumeUndo() async {
    if (!ifDefine(orderNo)) {
      showToast('暂无订单可撤销');
      return;
    }
    var res = await getrequest(
        "http://192.168.6.78:8055/api/Pay/ConsumeUndo",
        {
          "merId": "777290058168478",
          "orderNo": orderNo,
        },
        null,
        null,
        showDlog: true);
    var d = json.decode(res.data);
    if (d["Code"] != 0) {
      showToast(d["Msg"]);
      return;
    } else {
      showToast(d["Result"]["revokeStatus"]);
    }
  }

  ///3.5.退货
  Future<Null> _orderRefund() async {
    if (!ifDefine(orderNo)) {
      showToast('暂无订单可退货');
      return;
    }
    var res = await getrequest(
        "http://192.168.6.78:8055/api/Pay/OrderRefund",
        {
          "merId": "777290058168478",
          "orderNo": orderNo,
          "OrderAmount": orderAmount,
        },
        null,
        null,
        showDlog: true);
    var d = json.decode(res.data);
    if (d["Code"] != 0) {
      showToast(d["Msg"]);
      return;
    } else {
      showToast(d["Result"]["revokeStatus"]);
    }
  }

  /// http请求
  getrequest(url, Map params, Map<String, dynamic> header, Options option,
      {noTip = false, showDlog = false}) async {
    var callback;
    var res =
        await httpManager.netFetch(url, params, header, option, noTip: noTip);
    if (callback != null) callback();
    print(url + "---" + params.toString());
    print(url + "---" + res.data.toString());
    return res;
  }

  /// 检验是否有值且为有效值 是返回 true 否返回 false
  ifDefine(value) {
    if (value == null ||
        value == 'undefined' ||
        value == 'null' ||
        value == '(null)' ||
        value == 'NULL' ||
        value.trim() == '') {
      return false;
    } else {
      return true;
    }
  }

  /// 弹出 Toast 框
  /// msg 提示的信息 String
  showToast(msg, {int timeInSecForIos}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: timeInSecForIos == null ? 1 : timeInSecForIos,
    );
  }
}
