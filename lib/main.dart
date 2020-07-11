import 'package:flutter/material.dart';
import 'package:flutter_qiita_api/qiita_web_view.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qiita API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qiita API DEMO'),
      ),
      body: Center(
        child: Column(
          children: [
            FlatButton(
              child: const Text('webViewで認証'),
              onPressed: () async => _onCreateWebView(context),
            ),
            FlatButton(
              child: const Text('flutter_web_authで認証'),
              onPressed: () async => _onFlutterWebAuth(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onFlutterWebAuth() async {
    const clientId = '658d6eb1968088cfdb3015a2616100faa65522b1';
    const callbackUrl = 'qiita-api-sample://callback';
    final state = DateTime.now().millisecondsSinceEpoch.toString();
    final authorizedUrl = _getAuthorizedUrl(
      clientId: clientId,
      callbackUrl: callbackUrl,
      state: state,
    );
    const callbackUrlScheme = 'qiita-api-sample';

    final result = await FlutterWebAuth.authenticate(
        url: authorizedUrl, callbackUrlScheme: callbackUrlScheme);
    final parsedUrl = Uri.parse(result);
    final resState = parsedUrl.queryParameters['state'];
    if (state != resState) {
      return;
    }
    final code = parsedUrl.queryParameters['code'];
    final response = await http.post(
      'https://qiita.com/api/v2/access_tokens',
      body: {
        'client_id': clientId,
        'client_secret': '3be5578d77b7cccbe90a2342511684bfcc541ca0',
        'code': code,
      },
    );
    print(response.statusCode);
  }

  Future<void> _onCreateWebView(BuildContext context) async {
    const clientId = '658d6eb1968088cfdb3015a2616100faa65522b1';
    const callbackUrl = 'qiita-api-sample://callback';
    final state = DateTime.now().millisecondsSinceEpoch.toString();
    final authorizedUrl = _getAuthorizedUrl(
      clientId: clientId,
      callbackUrl: callbackUrl,
      state: state,
    );

    final responseUrl = await Navigator.of(context).push(
      MaterialPageRoute<PageRoute>(
        builder: (context) => QiitaWebView(
          url: authorizedUrl,
          callbackURl: callbackUrl,
        ),
      ),
    );
    print(responseUrl);
  }

  String _getAuthorizedUrl(
      {String clientId, String callbackUrl, String state}) {
    final url = Uri.https('qiita.com', '/api/v2/oauth/authorize', {
      'client_id': clientId,
      'redirect_uri': callbackUrl,
      'scope': 'read_qiita write_qiita',
      'state': state,
    });
    return url.toString();
  }
}
