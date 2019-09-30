import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_error_report/handle/console_handler.dart';
import 'package:flutter_error_report/handle/http_handler.dart';
import 'package:flutter_error_report/model/report.dart';
import 'package:flutter_error_report/util/check_app_type.dart';

import 'package:package_info/package_info.dart';


class ErrorReport {
  /// 根widget 必填
  final Widget rootWidget;
  /// 上报的后台地址 避谈
  final Uri uri;
  /// 自定义参数 例如：用户id
  Map<String, dynamic> customParameters=Map();

  /// 设备信息
  Map<String, dynamic> _deviceParameters = Map();
  /// app信息
  Map<String, dynamic> _applicationParameters = Map();


  ErrorReport( {@required this.rootWidget,@required this.uri, @required this.customParameters}) {
    _configure();
  }

  /// 配置ErrorReport
  _configure(){
    _loadDeviceInfo();
    _loadApplicationInfo();
    _setupErrorHooks();
  }


  /// 加载设备信息
  _loadDeviceInfo() {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      deviceInfo.androidInfo.then((androidInfo) {
        _loadAndroidParameters(androidInfo);
      });
    } else {
      deviceInfo.iosInfo.then((iosInfo) {
        _loadIosParameters(iosInfo);
      });
    }
  }


  /// 加载安卓设备信息
  void _loadAndroidParameters(AndroidDeviceInfo androidDeviceInfo) {
    _deviceParameters["id"] = androidDeviceInfo.id;
    _deviceParameters["androidId"] = androidDeviceInfo.androidId;
    _deviceParameters["board"] = androidDeviceInfo.board;
    _deviceParameters["bootloader"] = androidDeviceInfo.bootloader;
    _deviceParameters["brand"] = androidDeviceInfo.brand;
    _deviceParameters["device"] = androidDeviceInfo.device;
    _deviceParameters["display"] = androidDeviceInfo.display;
    _deviceParameters["fingerprint"] = androidDeviceInfo.fingerprint;
    _deviceParameters["hardware"] = androidDeviceInfo.hardware;
    _deviceParameters["host"] = androidDeviceInfo.host;
    _deviceParameters["isPsychicalDevice"] = androidDeviceInfo.isPhysicalDevice;
    _deviceParameters["manufacturer"] = androidDeviceInfo.manufacturer;
    _deviceParameters["model"] = androidDeviceInfo.model;
    _deviceParameters["product"] = androidDeviceInfo.product;
    _deviceParameters["tags"] = androidDeviceInfo.tags;
    _deviceParameters["type"] = androidDeviceInfo.type;
    _deviceParameters["versionBaseOs"] = androidDeviceInfo.version.baseOS;
    _deviceParameters["versionCodename"] = androidDeviceInfo.version.codename;
    _deviceParameters["versionIncremental"] =
        androidDeviceInfo.version.incremental;
    _deviceParameters["versionPreviewSdk"] =
        androidDeviceInfo.version.previewSdkInt;
    _deviceParameters["versionRelase"] = androidDeviceInfo.version.release;
    _deviceParameters["versionSdk"] = androidDeviceInfo.version.sdkInt;
    _deviceParameters["versionSecurityPatch"] =
        androidDeviceInfo.version.securityPatch;
  }

  /// 加载ios设备信息
  void _loadIosParameters(IosDeviceInfo iosInfo) {
    _deviceParameters["model"] = iosInfo.model;
    _deviceParameters["isPsychicalDevice"] = iosInfo.isPhysicalDevice;
    _deviceParameters["name"] = iosInfo.name;
    _deviceParameters["identifierForVendor"] = iosInfo.identifierForVendor;
    _deviceParameters["localizedModel"] = iosInfo.localizedModel;
    _deviceParameters["systemName"] = iosInfo.systemName;
    _deviceParameters["utsnameVersion"] = iosInfo.utsname.version;
    _deviceParameters["utsnameRelease"] = iosInfo.utsname.release;
    _deviceParameters["utsnameMachine"] = iosInfo.utsname.machine;
    _deviceParameters["utsnameNodename"] = iosInfo.utsname.nodename;
    _deviceParameters["utsnameSysname"] = iosInfo.utsname.sysname;
  }


  /// 加载app信息
  void _loadApplicationInfo() {
    PackageInfo.fromPlatform().then((packageInfo) {
      _applicationParameters["version"] = packageInfo.version;
      _applicationParameters["appName"] = packageInfo.appName;
      _applicationParameters["buildNumber"] = packageInfo.buildNumber;
      _applicationParameters["packageName"] = packageInfo.packageName;
      _applicationParameters["environment"] = CheckAppType.checkAppType().toString();
    });
  }

  /// 捕获异常，并处理异常，
  /// debug/profile模式打印异常，
  /// release模式上报异常
  _setupErrorHooks() {
    FlutterError.onError = (FlutterErrorDetails details) async {
      await _reportError(details.exception, details.stack);
    };

    Isolate.current.addErrorListener(new RawReceivePort((dynamic pair) async {
      var isolateError = pair as List<dynamic>;
      await _reportError(
        isolateError.first.toString(),
        isolateError.last.toString(),
      );
    }).sendPort);

    runZoned(() async {
      runApp(rootWidget);
    }, onError: (error, stackTrace) async {
      await _reportError(error, stackTrace);
    });
  }


  _reportError(dynamic error, dynamic stackTrace) async {
    Report report = Report(error, stackTrace, DateTime.now(), _deviceParameters,
        _applicationParameters, this.customParameters);
    if(kDebugMode){
      ConsoleHandler().handle(report);
    }else if(kProfileMode){
      ConsoleHandler().handle(report);
    }else{
      HttpHandler(endpointUri:this.uri).handle(report);
    }
  }

}