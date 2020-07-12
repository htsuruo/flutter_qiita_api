import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiita_api/qiita_user.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

class QiitaClient {
  QiitaClient({
    @required this.clientId,
    @required this.clientSecret,
    @required this.callbackUrlScheme,
    this.callbackUrl,
    this.scope = 'read_qiita write_qiita',
  });

  final String clientId;
  final String clientSecret;
  final String callbackUrlScheme;
  final String callbackUrl;
  final String scope;
  String get authorizedUrl => _getAuthorizedUrl();
  static const _domain = 'qiita.com';
  static const _host = 'https://$_domain';
  String _reqState;

  String _getAuthorizedUrl() {
    _reqState = DateTime.now().millisecondsSinceEpoch.toString();
    final url = Uri.https(_domain, Endpoint.authorize, {
      'client_id': clientId,
      'redirect_uri': callbackUrl,
      'scope': scope,
      'state': _reqState,
    });
    return url.toString();
  }

  Future<String> getAuthorizeCode() async {
    try {
      final result = await FlutterWebAuth.authenticate(
        url: authorizedUrl,
        callbackUrlScheme: callbackUrlScheme,
      );
      final parsedUrl = Uri.parse(result);
      final resState = parsedUrl.queryParameters['state'];
      if (_reqState != resState) {
        return null;
      }
      final code = parsedUrl.queryParameters['code'];
      return code;
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> getAccessToken({@required String code}) async {
    /// Qiitaは`application/json`のみ対応なので明示が必要
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final data = <String, String>{
      'client_id': clientId,
      'client_secret': clientSecret,
      'code': code,
    };
    final body = json.encode(data);
    final response = await http.post(
      '$_host${Endpoint.accessToken}',
      headers: headers,
      body: body,
    );
    if (response.statusCode != 201) {
      return null;
    }
    final accessToken = jsonDecode(response.body)['token'].toString();
    print('access token is : $accessToken');
    return accessToken;
  }

  Future<QiitaUser> getAuthUser({@required String accessToken}) async {
    final authHeaders = <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final authUser = await http.get(
      '$_host${Endpoint.userInfo}',
      headers: authHeaders,
    );
    if (authUser.statusCode != 200) {
      return null;
    }
    final json = jsonDecode(authUser.body) as Map<String, dynamic>;
    return QiitaUser.fromJson(json);
  }
}

class Endpoint {
  static const authorize = '/api/v2/oauth/authorize';
  static const accessToken = '/api/v2/access_tokens';
  static const userInfo = '/api/v2/authenticated_user';
}
