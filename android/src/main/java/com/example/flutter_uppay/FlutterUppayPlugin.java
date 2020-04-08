package com.example.flutter_uppay;

import android.app.Activity;
import android.content.Intent;

import com.unionpay.UPPayAssistEx;


import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterUppayPlugin
 */
public class FlutterUppayPlugin implements MethodCallHandler {
    private Activity activity;
    public static Result result;

    private FlutterUppayPlugin(Activity activity) {
        this.activity = activity;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_uppay");
        channel.setMethodCallHandler(new FlutterUppayPlugin(registrar.activity()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        this.result = result;
        if (call.method.equals("getPlatformVersion")) {
            Log.e("flutter", "原生接受到--getPlatformVersion");
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("toPay")) {

            //解析参数
            String tn = call.argument("tn");
            String mode = call.argument("mode");
            Log.e("flutter", "原生接受到--" + tn);
            //调起云闪付控件
            UPPayAssistEx.startPay(activity, null, null, tn, mode);
//            activity.startActivity(new Intent(activity, JARActivity.class));
        } else {
            result.notImplemented();
        }
    }

}
