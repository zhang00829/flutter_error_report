import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_error_report/model/report.dart';

class HttpHandler {
  final Dio dio=Dio();

  final Uri endpointUri;

  HttpHandler({@required this.endpointUri}) {
    assert(this.endpointUri != null, "Endpoint uri can't be null");
  }

  void handle(Report report) async {
    var json = report.toJson();
    dio.post(endpointUri.toString(), data: json).catchError(() => {});
  }
}
