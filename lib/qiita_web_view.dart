import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QiitaWebView extends StatelessWidget {
  const QiitaWebView({
    Key key,
    @required this.url,
    @required this.callbackURl,
  }) : super(key: key);

  final String url;
  final String callbackURl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qiita 認可画面'),
      ),
      body: WebView(
        initialUrl: url.toString(),
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (request) {
          if (request.url.startsWith(callbackURl)) {
            Navigator.pop(context, request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
