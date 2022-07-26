import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:biovillage/helpers/sentry.dart';
import 'package:biovillage/helpers/net-connection.dart';

// Ф-ия декодирования ответа
dynamic _jsonParseBytes(Uint8List bytes) {
  return json.decode(utf8.decode(bytes));
}

class ApiClient {
  /// Базовый API URL
  static final String defaultApiDomen = DotEnv().env['API_DOMEN'];
  static final String defaultApiBase = DotEnv().env['API_BASE_PATH'];

  /// Обработчик запросов
  handleRequest({@required Function request}) async {
    // Проверка подключения к интернету:
    if (!await checkConnect(null, toast: false)) return null;
    // Выполенение запроса:
    try {
      http.Response response = await request();
      var result = await compute(_jsonParseBytes, response.bodyBytes);
      if (response.statusCode == 200) {
        return result;
      } else {
        String method = response.request.method;
        String url = response.request.url.toString();
        String error = 'ApiClient [$method $url] returned ${response.statusCode} status ==> $result';
        print(error);
        Sentry.client.captureException(exception: error);
        return result;
      }
    } catch (error, stackTrace) {
      print('ApiClient ERROR: $error');
      Sentry.client.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Формирование заголовков для запроса
  buildRequestHeaders({String userToken}) {
    Map<String, String> headers = {};
    // Если передан токен, то добавляем и его:
    if (userToken != null && userToken != '') headers['Authorization'] = 'Bearer $userToken';
    return headers;
  }

  /// GET запрос к апи
  Future getRequest({
    String apiDomen,
    @required String url,
    String userToken,
    Map<String, String> params,
  }) async {
    if (apiDomen == null) {
      apiDomen = defaultApiDomen;
      url = defaultApiBase + url;
    }

    ApiClient client = ApiClient();
    return await client.handleRequest(
      request: () => http.get(
        Uri.https(apiDomen, url, params),
        headers: client.buildRequestHeaders(userToken: userToken),
      ),
    );
  }

  /// POST запрос к апи
  Future postRequest({
    String apiDomen,
    @required String url,
    String userToken,
    Map<String, String> body,
  }) async {
    if (apiDomen == null) {
      apiDomen = defaultApiDomen;
      url = defaultApiBase + url;
    }

    ApiClient client = ApiClient();
    return await client.handleRequest(
      request: () => http.post(
        Uri.https(apiDomen, url),
        encoding: Encoding.getByName('utf-8'),
        headers: client.buildRequestHeaders(userToken: userToken),
        body: body,
      ),
    );
  }

  /// DELETE запрос к апи
  Future deleteRequest({
    String apiDomen,
    @required String url,
    String userToken,
    Map<String, String> params,
  }) async {
    if (apiDomen == null) {
      apiDomen = defaultApiDomen;
      url = defaultApiBase + url;
    }

    ApiClient client = ApiClient();
    return await client.handleRequest(
      request: () => http.delete(
        Uri.https(apiDomen, url, params),
        headers: client.buildRequestHeaders(userToken: userToken),
      ),
    );
  }
}
