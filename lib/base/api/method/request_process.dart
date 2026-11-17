import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../endpoint/api_endpoint.dart';
import '../services/api_services.dart';
import 'api_method.dart';

class RequestProcess extends GetxController {
  Future<T?> request<T>({
    required T Function(Map<String, dynamic>) fromJson,
    required ApiEndpoint apiEndpoint,
    required RxBool isLoading,
    bool showResult = false,
    bool showSuccessMessage = false,
    bool isBasic = false,
    required Function(T?) onSuccess,
    HttpMethod method = HttpMethod.GET,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Function(Object)? onError,
    List<String>? fieldList,
    List<String>? pathList,
    bool showErrorMessage = true,
  }) async {
    Map<String, String>? stringBody =
    body?.map((key, value) => MapEntry(key, value.toString()));
    try {
      isLoading.value = true;
      update();
      final String endpointUrl = apiEndpoint.url(params: queryParams);

      if (kDebugMode) {
        developer.log('═══════════════════════════════════════════════════════════');
        developer.log('📡 API REQUEST START');
        developer.log('═══════════════════════════════════════════════════════════');
        developer.log('🔗 URL: $endpointUrl');
        developer.log('📝 Method: $method');
        developer.log('📦 Body: ${body ?? "null"}');
        developer.log('🔍 Query Params: ${queryParams ?? "null"}');
        developer.log('📋 Field List: ${fieldList ?? "null"}');
        developer.log('📁 Path List: ${pathList ?? "null"}');
        developer.log('═══════════════════════════════════════════════════════════');
      }
      
      T? value;
      if (method == HttpMethod.POST && fieldList != null && pathList != null) {
        if (kDebugMode) {
          developer.log('📤 Multipart Upload Request');
          developer.log('   Fields: $fieldList');
          developer.log('   Files: $pathList');
        }
        value = await ApiServices.multipartApiService<T>(
          fromJson,
          endpointUrl,
          stringBody ?? {},
          fieldList,
          pathList,
          showSuccessMessage: showSuccessMessage,
          isBasic: isBasic,
        );
      } else {
        String httpMethod = method == HttpMethod.POST ? 'POST' : method == HttpMethod.DELETE ? 'DELETE' : 'GET';
        if (kDebugMode) developer.log('📨 Standard $httpMethod Request');
        value = await ApiServices.apiService<T>(
          fromJson,
          endpointUrl,
          method: httpMethod,
          body: body,
          showResult: showResult,
          isBasic: isBasic,
          showSuccessMessage: showSuccessMessage,
          showErrorMessage: showErrorMessage,
        );
      }

      if (kDebugMode) {
        developer.log('═══════════════════════════════════════════════════════════');
        developer.log('✅ API RESPONSE');
        developer.log('📊 Type: ${value.runtimeType}');
        developer.log('📄 Value: $value');
        developer.log('═══════════════════════════════════════════════════════════');
      }

      // If API returned an error (null response), call onError instead of onSuccess
      if (value == null) {
        if (onError != null) {
          onError('API request failed');
        }
      } else {
        onSuccess(value);
      }
      return value;
    } catch (e) {
      if (kDebugMode) {
        developer.log('═══════════════════════════════════════════════════════════');
        developer.log('❌ API REQUEST ERROR');
        developer.log('🐞 Error Type: ${e.runtimeType}');
        developer.log('🐞 Error Message: $e');
        developer.log('🔗 URL: ${apiEndpoint.url(params: queryParams)}');
        developer.log('📝 Method: $method');
        developer.log('═══════════════════════════════════════════════════════════');
      }
      log.e('🐞🐞🐞 Error from API service: $e 🐞🐞🐞');
      if (onError != null) onError(e);
    } finally {
      isLoading.value = false;
      update();
    }
    return null;
  }
}

enum HttpMethod { GET, POST, DELETE }