import 'package:flutter/material.dart';
import 'package:flutter_error_report/model/report.dart';

class ConsoleHandler {
  final bool enableDeviceParameters;
  final bool enableApplicationParameters;
  final bool enableStackTrace;
  final bool enableCustomParameters;

  ConsoleHandler(
      {this.enableDeviceParameters = true,
      this.enableApplicationParameters = true,
      this.enableStackTrace = true,
      this.enableCustomParameters = true});

  void handle(Report report) {
    debugPrint(
        "============================== ErrorReport Log ==============================");
    debugPrint("Crash occured on ${report.dateTime}");
    debugPrint("");
    if (enableDeviceParameters) {
      _printDeviceParametersFormatted(report.deviceParameters);
      debugPrint("");
    }
    if (enableApplicationParameters) {
      _printApplicationParametersFormatted(report.applicationParameters);
      debugPrint("");
    }
    debugPrint("---------- ERROR ----------");
    debugPrint("${report.error}");
    debugPrint("");
    if (enableStackTrace) {
      _printStackTraceFormatted(report.stackTrace);
    }
    if (enableCustomParameters) {
      _printCustomParametersFormatted(report.customParameters);
    }
    debugPrint(
        "======================================================================");
  }

  _printDeviceParametersFormatted(Map<String, dynamic> deviceParameters) {
    debugPrint("------- DEVICE INFO -------");
    for (var entry in deviceParameters.entries) {
      debugPrint("${entry.key}: ${entry.value}");
    }
  }

  _printApplicationParametersFormatted(
      Map<String, dynamic> applicationParameters) {
    debugPrint("------- APP INFO -------");
    for (var entry in applicationParameters.entries) {
      debugPrint("${entry.key}: ${entry.value}");
    }
  }

  _printCustomParametersFormatted(Map<String, dynamic> customParameters) {
    debugPrint("------- CUSTOM INFO -------");
    for (var entry in customParameters.entries) {
      debugPrint("${entry.key}: ${entry.value}");
    }
  }

  _printStackTraceFormatted(StackTrace stackTrace) {
    debugPrint("------- STACK TRACE -------");
    for (var entry in stackTrace.toString().split("\n")) {
      debugPrint("$entry");
    }
  }
}
