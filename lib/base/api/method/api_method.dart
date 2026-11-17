import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../maintenance/maintenance_dialog.dart';
import '../../maintenance/maintenance_model.dart';
import '../../utils/api_error_handler.dart';
import '../../utils/basic_import.dart';
import '../../utils/local_storage.dart';
import '../../widgets/logger.dart';
import '../model/error_message_model.dart';
import '../../../routes/routes.dart';

final log = logger(ApiMethod);

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}

Future<Map<String, String>> bearerHeaderInfo() async {
  String accessToken = LocalStorage.token;

  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
}

class ApiMethod {
  ApiMethod({required this.isBasic, this.client});

  bool isBasic;
  http.Client? client;

  // Guard to prevent multiple simultaneous unauth redirects
  static bool _isHandlingUnauth = false;

  /// Returns true if the error was an unauth error (handled here).
  /// Returns false if it was something else (caller should show generic toast).
  bool _handleUnauthError(String errorMsg) {
    if (isBasic || _isHandlingUnauth) return false;

    final lowerMsg = errorMsg.toLowerCase();
    if (lowerMsg.contains('unauthenticated') ||
        lowerMsg.contains('access denied')) {
      _isHandlingUnauth = true;
      CustomSnackBar.error(errorMsg);
      LocalStorage.save(token: '', isLoggedIn: false);
      Get.offAllNamed(Routes.loginScreen);
      return true;
    }
    return false;
  }

  // Get method
  Future<Map<String, dynamic>?> get(
    String url, {
    int code = 200,
    int duration = 120,
    bool showResult = false,
    bool showErrorMessage = true,
  }) async {
    if (kDebugMode) {
      log.i(
        '|📍📍📍|----------------- [[ GET ]] method details start -----------------|📍📍📍|',
      );
      log.i(url);
      log.i(
        '|📍📍📍|----------------- [[ GET ]] method details ended -----------------|📍📍📍|',
      );
    }

    Future<http.Response> doGet() async {
      return (client ?? http.Client())
          .get(
            Uri.parse(url),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));
    }

    try {
      final response = await doGet();

      if (kDebugMode) {
        log.i(
          '|📒📒📒|-----------------[[ GET ]] method response start -----------------|📒📒📒|',
        );
        log.i('Status: ${response.statusCode}');
        log.i(response.body.toString());
        log.i(
          '|📒📒📒|-----------------[[ GET ]] method response end -----------------|📒📒📒|',
        );
      }

      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == code) {
        try {
          // Fix malformed JSON from backend
          String sanitizedBody = response.body
              // Fix "nul" instead of "null"
              .replaceAll(':nul,', ':null,')
              .replaceAll(':nul}', ':null}')
              .replaceAll(':nul]', ':null]')
              // Fix missing comma between quoted strings (only when there is
              // at least one non-quote character between the two quotes so that
              // legitimate empty-string values "" are never touched)
              .replaceAll(RegExp(r'"(\s+)"'), '","');

          return jsonDecode(sanitizedBody);
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${response.body.length}');
          log.e('Error: $e');
          if (showErrorMessage) {
            CustomSnackBar.error('Failed to process server response');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
            'unknown error hitted in status code${jsonDecode(response.body)}',
          );

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
          String errorMsg = res.message.error.join(', ');
          ApiErrorHandler.setError(errorMsg);
          if (isMaintenance) {
          } else {
            if (!_handleUnauthError(errorMsg) && showErrorMessage) {
              CustomSnackBar.error(errorMsg);
            }
          }
        } catch (e) {
          log.e('Failed to parse error response: $e');
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');
      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');
      if (showErrorMessage) {
        CustomSnackBar.error('Something Went Wrong! Try again');
      }
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      // Transient server/proxy resets sometimes happen mid-response.
      // Retry once to reduce flakiness for idempotent GET requests.
      if (err.toString().toLowerCase().contains(
        'connection closed while receiving data',
      )) {
        try {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          final retryResponse = await doGet();
          if (retryResponse.statusCode == code) {
            try {
              String sanitizedBody = retryResponse.body
                  .replaceAll(':nul,', ':null,')
                  .replaceAll(':nul}', ':null}')
                  .replaceAll(':nul]', ':null]')
                  .replaceAll(RegExp(r'"(\s+)"'), '","');
              return jsonDecode(sanitizedBody);
            } catch (e) {
              log.e('🐞🐞🐞 JSON Decode Error (retry) 🐞🐞🐞');
              log.e('Response length: ${retryResponse.body.length}');
              log.e('Error: $e');
              if (showErrorMessage) {
                CustomSnackBar.error('Failed to process server response');
              }
              return null;
            }
          }
        } catch (_) {
          // ignore retry errors; fall through
        }
      }

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> post(
    String url,
    Map<String, dynamic> body, {
    int code = 201,
    int duration = 120,
    bool showResult = false,
    bool showErrorMessage = true,
  }) async {
    try {
      if (kDebugMode) {
        log.i(
          '|📍📍📍|-----------------[[ POST ]] method details start -----------------|📍📍📍|',
        );
        log.i(url);
        log.i(body);
        log.i(
          '|📍📍📍|-----------------[[ POST ]] method details end ------------|📍📍📍|',
        );
      }

      final response = await (client ?? http.Client())
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      if (kDebugMode) {
        log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|',
        );
        log.i('Status: ${response.statusCode}');
        log.i(response.body.toString());
        log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|',
        );
      }
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == code) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${response.body.length}');
          log.e('Error: $e');
          if (showErrorMessage) {
            CustomSnackBar.error('Failed to process server response');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
            'unknown error hitted in status code ${jsonDecode(response.body)}',
          );

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
          String errorMsg = res.message.error.join(', ');
          ApiErrorHandler.setError(errorMsg);

          if (isMaintenance) {
          } else {
            if (!_handleUnauthError(errorMsg) && showErrorMessage) {
              CustomSnackBar.error(errorMsg);
            }
          }
        } catch (e) {
          log.e('Failed to parse error response: $e');
          ApiErrorHandler.setError(response.body);
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());
      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Delete Method
  Future<Map<String, dynamic>?> delete(
    String url, {
    int code = 200,
    int duration = 120,
    bool showResult = false,
    bool showErrorMessage = true,
  }) async {
    if (kDebugMode) {
      log.i(
        '|📍📍📍|----------------- [[ DELETE ]] method details start -----------------|📍📍📍|',
      );
      log.i(url);
      log.i(
        '|📍📍📍|----------------- [[ DELETE ]] method details ended -----------------|📍📍📍|',
      );
    }

    try {
      final response = await (client ?? http.Client())
          .delete(
            Uri.parse(url),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      if (kDebugMode) {
        log.i(
          '|📒📒📒|-----------------[[ DELETE ]] method response start -----------------|📒📒📒|',
        );
        log.i('Status: ${response.statusCode}');
        log.i(response.body.toString());
        log.i(
          '|📒📒📒|-----------------[[ DELETE ]] method response end -----------------|📒📒📒|',
        );
      }

      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == code) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${response.body.length}');
          log.e('Error: $e');
          if (showErrorMessage) {
            CustomSnackBar.error('Failed to process server response');
          }
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
            'unknown error hitted in status code${jsonDecode(response.body)}',
          );

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
          String errorMsg = res.message.error.join(', ');
          ApiErrorHandler.setError(errorMsg);
          if (isMaintenance) {
          } else {
            if (!_handleUnauthError(errorMsg) && showErrorMessage) {
              CustomSnackBar.error(errorMsg);
            }
          }
        } catch (e) {
          log.e('Failed to parse error response: $e');
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');
      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');
      if (showErrorMessage) {
        CustomSnackBar.error('Something Went Wrong! Try again');
      }
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> multipart(
    String url,
    Map<String, String> body,
    String filepath,
    String filedName, {
    int code = 200,
    bool showResult = false,
  }) async {
    try {
      if (kDebugMode) {
        log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|',
        );
        log.i(url);
        log.i(body);
        log.i(filepath);
        log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|',
        );
      }

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll(isBasic ? basicHeaderInfo() : await bearerHeaderInfo())
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      if (kDebugMode) {
        log.i(
          '|📒📒📒|-----------------[[ Multipart ]] method response start ----------------|📒📒📒|',
        );
        log.i('Status: ${response.statusCode} ${response.reasonPhrase}');
        log.i(jsonData.body.toString());
        log.i(
          '|📒📒📒|-----------------[[ Multipart ]] method response end --------------------|📒📒📒|',
        );
      }
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        try {
          return jsonDecode(jsonData.body) as Map<String, dynamic>;
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${jsonData.body.length}');
          log.e('Error: $e');
          CustomSnackBar.error('Failed to process server response');
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
            'unknown error hitted in status code ${jsonDecode(jsonData.body)}',
          );

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));
          String errorMsg = res.message.error.join(', ');

          if (!isMaintenance && !_handleUnauthError(errorMsg)) {
            CustomSnackBar.error(errorMsg);
          }
        } catch (e) {
          log.e('Failed to parse error response: $e');
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // multipart multi file Method
  Future<Map<String, dynamic>?> multipartMultiFile(
    String url,
    Map<String, String> body, {
    int code = 200,
    bool showResult = false,
    required List<String> pathList,
    required List<String> fieldList,
  }) async {
    try {
      if (kDebugMode) {
        log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|',
        );
        log.i(url);
        log.i(body);
        log.i(pathList);
        log.i(fieldList);
        log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|',
        );
      }
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        );

      // Add files and log their details
      for (int i = 0; i < fieldList.length; i++) {
        if (kDebugMode) {
          final file = File(pathList[i]);
          final fileSize = await file.length();
          final fileName = pathList[i].split('/').last;
          log.i(
            'File ${i + 1}: field=${fieldList[i]} name=$fileName size=${(fileSize / 1024).toStringAsFixed(2)}KB',
          );
        }
        request.files.add(
          await http.MultipartFile.fromPath(fieldList[i], pathList[i]),
        );
      }
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      if (kDebugMode) {
        log.i(
          '|📒📒📒|-----------------[[ Multipart ]] method response start-----------------|📒📒📒|',
        );
        log.i('Status: ${response.statusCode} ${response.reasonPhrase}');
        log.i(jsonData.body);
        log.i(
          '|📒📒📒|-----------------[[ Multipart ]] method response end-----------------|📒📒📒|',
        );
      }
      bool isMaintenance = response.statusCode == 503;
      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        try {
          return jsonDecode(jsonData.body) as Map<String, dynamic>;
        } catch (e) {
          log.e('🐞🐞🐞 JSON Decode Error 🐞🐞🐞');
          log.e('Response length: ${jsonData.body.length}');
          log.e('Error: $e');
          CustomSnackBar.error('Failed to process server response');
          return null;
        }
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        try {
          log.e(
            'unknown error hitted in status code ${jsonDecode(jsonData.body)}',
          );

          ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));
          String errorMsg = res.message.error.join(', ');

          if (!isMaintenance && !_handleUnauthError(errorMsg)) {
            CustomSnackBar.error(errorMsg);
          }
        } catch (e) {
          log.e('Failed to parse error response: $e');
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  void _maintenanceCheck(bool isMaintenance, var jsonData) {
    final controller = Get.put(SystemMaintenanceController());
    if (isMaintenance) {
      controller.maintenanceStatus.value = true;
      MaintenanceModel maintenanceModel = MaintenanceModel.fromJson(
        jsonDecode(jsonData),
      );
      MaintenanceDialog().show(maintenanceModel: maintenanceModel);
    } else {
      controller.maintenanceStatus.value = false;
    }
  }
}
