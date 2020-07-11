import 'package:flutter/material.dart';
import 'package:flutter_qiita_api/qiita_client.dart';
import 'package:flutter_qiita_api/qiita_user.dart';
import 'package:flutter_qiita_api/qiita_web_view.dart';

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
        primaryColor: const Color(0xFF55c500),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QiitaUser loggedInUser;

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
              child: const Text('flutter_web_authで認証'),
              onPressed: () async => _onFlutterWebAuth(),
            ),
            FlatButton(
              child: const Text('webViewで認証'),
              onPressed: () async => _onCreateWebView(context),
            ),
            const Divider(),
            loggedInUser != null
                ? ListTile(
                    title: Text('${loggedInUser.id} でログイン中'),
                    subtitle: loggedInUser.description != null
                        ? Text(loggedInUser.description)
                        : null,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _onFlutterWebAuth() async {
    final client = QiitaClient(
      clientId: 'xxxxxxxxxxxxxxxxxxxx',
      clientSecret: 'xxxxxxxxxxxxxxxxxxxx',
      callbackUrlScheme: 'xxxxx', //qiita-api-sample
      callbackUrl: 'xxxx', //qiita-api-sample://callback
    );

    final code = await client.getAuthorizeCode();
    if (code == null) {
      return;
    }
    final accessToken = await client.getAccessToken(code: code);
    final user = await client.getAuthUser(accessToken: accessToken);
    setState(() {
      loggedInUser = user;
    });
  }

  Future<void> _onCreateWebView(BuildContext context) async {
    final client = QiitaClient(
      clientId: 'xxxxxxxxxxxxxxxxxxxx',
      clientSecret: 'xxxxxxxxxxxxxxxxxxxx',
      callbackUrlScheme: 'xxxxx', //qiita-api-sample
      callbackUrl: 'xxxx', //qiita-api-sample://callback
    );
    final responseUrl = await Navigator.of(context).push(
      MaterialPageRoute<PageRoute>(
        builder: (context) => QiitaWebView(
          url: client.authorizedUrl,
          callbackURl: client.callbackUrl,
        ),
        fullscreenDialog: true,
      ),
    );
    print(responseUrl);
  }
}
