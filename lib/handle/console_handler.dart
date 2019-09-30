
import 'package:flutter_error_report/model/report.dart';
import 'package:logging/logging.dart';

class ConsoleHandler  {
  final bool enableDeviceParameters;
  final bool enableApplicationParameters;
  final bool enableStackTrace;
  final bool enableCustomParameters;
  Logger _logger = Logger("ConsoleHandler");

  ConsoleHandler(
      {this.enableDeviceParameters = true,
        this.enableApplicationParameters = true,
        this.enableStackTrace = true,
        this.enableCustomParameters = true});

  Future<bool> handle(Report report) {
    _logger.info(
        "============================== CATCHER LOG ==============================");
    _logger.info("Crash occured on ${report.dateTime}");
    _logger.info("");
    if (enableDeviceParameters) {
      _printDeviceParametersFormatted(report.deviceParameters);
      _logger.info("");
    }
    if (enableApplicationParameters) {
      _printApplicationParametersFormatted(report.applicationParameters);
      _logger.info("");
    }
    _logger.info("---------- ERROR ----------");
    _logger.info("${report.error}");
    _logger.info("");
    if (enableStackTrace) {
      _printStackTraceFormatted(report.stackTrace);
    }
    if (enableCustomParameters) {
      _printCustomParametersFormatted(report.customParameters);
    }
    _logger.info(
        "======================================================================");
    return Future.value(true);
  }

  _printDeviceParametersFormatted(Map<String, dynamic> deviceParameters) {
    _logger.info("------- DEVICE INFO -------");
    for (var entry in deviceParameters.entries) {
      _logger.info("${entry.key}: ${entry.value}");
    }
  }

  _printApplicationParametersFormatted(
      Map<String, dynamic> applicationParameters) {
    _logger.info("------- APP INFO -------");
    for (var entry in applicationParameters.entries) {
      _logger.info("${entry.key}: ${entry.value}");
    }
  }

  _printCustomParametersFormatted(Map<String, dynamic> customParameters) {
    _logger.info("------- CUSTOM INFO -------");
    for (var entry in customParameters.entries) {
      _logger.info("${entry.key}: ${entry.value}");
    }
  }

  _printStackTraceFormatted(StackTrace stackTrace) {
    _logger.info("------- STACK TRACE -------");
    for (var entry in stackTrace.toString().split("\n")) {
      _logger.info("$entry");
    }
  }
}
