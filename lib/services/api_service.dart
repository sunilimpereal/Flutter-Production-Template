import 'dart:developer';

import 'package:flutter_production_template/models/error_response.dart';
import 'package:flutter_production_template/utils/sharedPrefs.dart';
import 'package:http/http.dart' as http;

class Response<ResModel> {
  ResModel? response;
  String? error;
  Response({
    this.response,
    this.error,
  });
}

class ApiRequest<ReqModel, ResModel> {
  Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${sharedPrefs.authToken}',
  };
  Future<Response<ResModel>> post({
    required String url,
    required ReqModel request,
    required ResModel Function(String) reponseFromJson,
    required String Function(ReqModel) requestToJson,
  }) async {
    // try {
    var uri = Uri.parse(url);
    log("ApiRequest POST : $uri");
    log("ApiRequest Body : ${requestToJson(request)}");
    var response = await http.post(
      uri,
      body: requestToJson(request),
      headers: requestHeaders,
    );
    log("ApiRequest Response ${response.statusCode} : ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      ResModel responseModel = reponseFromJson(response.body);
      return Response(response: responseModel);
      // return Response( responseModel;
    }
    if (response.statusCode == 400) {
      ErrorResponse errorResponse = errorResponseFromJson(response.body);
      return Response(error: errorResponse.error);
    }
    return Response();

    // } catch (e) {
    //   return null;
    // }
  }

  Future<ResModel?> get({
    required String url,
    required Function(String) reponseFromJson,
  }) async {
    http.Response response;
    try {
      var uri = Uri.parse(url);
      log("ApiRequest GET : $uri");
      response = await http.get(
        uri,
        headers: requestHeaders,
      );
      log("ApiRequest Response ${response.statusCode} : ${response.body}");
      if (response.statusCode == 200) {
        log(response.body);
        ResModel responseModel = reponseFromJson(response.body);
        return responseModel;
      }
      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}