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
  QiitaUser user;

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
              child: const Text('flutter_web_authで認可'),
              onPressed: () async => _onFlutterWebAuth(),
            ),
            FlatButton(
              child: const Text('webViewで認可'),
              onPressed: () async => _onCreateWebView(context),
            ),
            const Divider(),
            user != null
                ? ListTile(
                    title: Text('${user.id} を取得'),
                    subtitle: user.description != null
                        ? Text(user.description)
                        : null,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  /// flutter_web_authを利用（内部でPlatform Channelsを利用）
  /// iOS:ASWebAuthenticationSession（アプリ内Safariのようなもの）を間接的に利用
  /// Android: Chrome Custom Tabsを間接的に利用（一度別ブラウザに飛ぶような遷移になる）
  /// callbackUrlSchemeと一致すると該当のアプリに戻ってくる
  Future<void> _onFlutterWebAuth() async {
    final client = QiitaClient(
      clientId: 'xxxxxxxxxxxxxxxxxxxx',
      clientSecret: 'xxxxxxxxxxxxxxxxxxxx',
      callbackUrlScheme: 'xxxxx', //qiita-api-sample
    );

    final code = await client.getAuthorizeCode();
    if (code == null) {
      return;
    }
    final accessToken = await client.getAccessToken(code: code);
    final _user = await client.getAuthUser(accessToken: accessToken);
    setState(() {
      user = _user;
    });
  }

  /// webview_flutterを利用
  /// ディープリンクで戻ってくるのではなく、NaivigatorDelegateで毎回URLの変更を検知する
  /// コールバックURLに変化したらNavigator.popなどで画面を閉じる
  /// コールバックURLを文字列で判別するので実在しなくても問題なさそうな雰囲気
  Future<void> _onCreateWebView(BuildContext context) async {
    final client = QiitaClient(
      clientId: 'xxxxxxxxxxxxxxxxxxxx',
      clientSecret: 'xxxxxxxxxxxxxxxxxxxx',
      callbackUrl: 'xxxxx', //qiita-api-sample://callback
    );
    final responseUrl = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => QiitaWebView(
          url: client.authorizedUrl,
          callbackURl: client.callbackUrl,
        ),
        fullscreenDialog: true,
      ),
    );
    final code = client.validateCode(urlString: responseUrl);
    if (code == null) {
      return;
    }
    final accessToken = await client.getAccessToken(code: code);
    final _user = await client.getAuthUser(accessToken: accessToken);
    setState(() {
      user = _user;
    });
  }
}
