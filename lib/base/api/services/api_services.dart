import 'dart:io';
import 'package:http/http.dart' as http;
import '../../utils/basic_import.dart';
import '../method/api_method.dart';
import '../model/common_success_model.dart';

class ApiServices {
  // Create a custom HTTP client that ignores self-signed certificates
  static final _client = http.Client();

  // Generic API service method
  static Future<T?> apiService<T>(
    T Function(Map<String, dynamic>) fromJson,
    String apiEndpoint, {
    Map<String, dynamic>? body,
    String method = 'GET',
    int statusCode = 200,
    bool showResult = false,
    bool isBasic = false,
    bool showSuccessMessage = false,
    bool showErrorMessage = true,
    String tostTitle = 'Success',
  }) async {
    try {
      Map<String, dynamic>? mapResponse;

      // Pass the custom client to ApiMethod
      final apiMethod = ApiMethod(isBasic: isBasic, client: _client);

      if (method == 'POST') {
        mapResponse = await apiMethod.post(
          apiEndpoint,
          body ?? {},
          code: statusCode,
          showErrorMessage: showErrorMessage,
        );
      } else if (method == 'DELETE') {
        mapResponse = await apiMethod.delete(
          apiEndpoint,
          code: statusCode,
          showErrorMessage: showErrorMessage,
        );
      } else if (method == 'GET') {
        mapResponse = await apiMethod.get(
          apiEndpoint,
          showResult: showResult,
          showErrorMessage: showErrorMessage,
        );
      }

      if (mapResponse != null) {
        return _handleResponse<T>(
            mapResponse, fromJson, showSuccessMessage, tostTitle);
      } else {
        log.e('🐞🐞🐞 err from ApiService ==> $apiEndpoint 🐞🐞🐞');
      }
    } catch (e) {
      log.e('🐞🐞🐞 err from ApiService ==> $e 🐞🐞🐞');
      CustomSnackBar.error('Something went wrong!');
    }
    return null;
  }

  // Method for multipart file uploads
  static Future<T?> multipartApiService<T>(
    T Function(Map<String, dynamic>) fromJson,
    String apiEndpoint,
    Map<String, String> body,
    List<String> fieldList,
    List<String> pathList, {
    int statusCode = 200,
    bool isBasic = false,
    bool showSuccessMessage = false,
    String tostTitle = Strings.success,
  }) async {
    log.i('ApiServices multipartApiService called endpoint: $apiEndpoint');
    log.i('ApiServices multipartApiService fieldList: $fieldList pathList: $pathList');
    try {
      Map<String, dynamic>? mapResponse =
          await ApiMethod(isBasic: isBasic).multipartMultiFile(
        apiEndpoint,
        body,
        fieldList: fieldList,
        pathList: pathList,
      );

      log.i('ApiServices multipartApiService mapResponse: $mapResponse');
      if (mapResponse != null) {
        log.i('ApiServices multipartApiService calling _handleResponse');
        return _handleResponse<T>(
            mapResponse, fromJson, showSuccessMessage, tostTitle);
      } else {
        log.i('ApiServices multipartApiService mapResponse is null');
      }
    } catch (e) {
      log.e('🐞🐞🐞 err from multipartApiService ==> $e 🐞🐞🐞');
      CustomSnackBar.error('Something went wrong!');
    }
    return null;
  }

  // Helper method to handle responses
  static T? _handleResponse<T>(
    Map<String, dynamic> mapResponse,
    T Function(Map<String, dynamic>) fromJson,
    bool showSuccessMessage,
    String tostTitle,
  ) {
    log.i('ApiServices _handleResponse called mapResponse: $mapResponse');
    log.i('ApiServices _handleResponse calling fromJson');
    T result = fromJson(mapResponse);
    log.i('ApiServices _handleResponse fromJson result: $result');

    if (showSuccessMessage) {
      var messages = CommonSuccessModel.fromJson(mapResponse);
      CustomSnackBar.success(
        title: tostTitle,
        message: messages.message.success.first.toString(),
      );
    }

    return result;
  }
}