import 'package:flutter/material.dart';
import 'package:hc_mes_app/pages/positionPage/index.dart';
import 'package:provider/provider.dart';
import 'common/login_prefs.dart';
import './pages/login/login.dart';
import './pages/home/home.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './common/dio_request.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
// import 'package:media_kit_video/media_kit_video.dart';

import 'package:auto_updater/auto_updater.dart';
import 'package:hc_mes_app/utils/init.dart';
import '../../common/constant.dart';
import 'dart:io';

// 获取当前设备的IP地址
Map getLocalMacAddress() {
  ProcessResult process = Process.runSync('ipconfig', ['/all']);
  String output = process.stdout;
  List<String> lines = output.split('\r\n');
  var macAddress = lines
      .where((element) => element.contains('物理地址'))
      .toList()
      .map((item) => item.split(':').last.trim())
      .toList();
  var ipAddress = lines
      .where((element) => element.contains('IPv4'))
      .toList()
      .last
      .split(':')
      .last
      .split('(')
      .first
      .trim();
  print(lines
      .where((element) => element.contains('物理地址'))
      .toList()
      .map((item) => item.split(':').last.trim())
      .toList());
  print(lines.where((element) => element.contains('IPv4')).toList());
  print('物理地址：${macAddress}');
  print('ip地址${ipAddress}');
  return {'mac': macAddress, 'ip': ipAddress};
}

void main() async {
  print(getLocalMacAddress()['mac'].length);

  // print('anyIPv4: ${InternetAddress.address}');
  // print('loopbackIPv4: ${InternetAddress.loopbackIPv4.toString()}');
  // // var ipAddress =
  // //     await InternetAddress.lookup(InternetAddress.loopbackIPv4.toString());
  // final result = await InternetAddress.lookup('DESKTOP-TR4ANSP',
  //     type: InternetAddressType.IPv4);
  // print('Local IP Address result: ${result.toString()}');
  WidgetsFlutterBinding.ensureInitialized();
  // Future getFeedURL() async {
  //   var password = await encodeString('Hm123456*');
  //   print('用户信息：${password}');
  //   var params = {
  //     // 'barCode': username.text,
  //     "userName": "10003",
  //     'password': password,
  //   };
  //   var response = await Request.post(
  //     "/rest/core/auth/login",
  //     data: params,
  //     baseUrl: Constant.zdUrl,
  //   );
  //   print('接口返回数据：${response}');
  //   if (response["state"]) {
  //     // LoginPrefs.saveIdentitytoken(response["identitytoken"]);
  //     // return response["identitytoken"];
  //   } else {
  //     // EasyLoading.showError(response["message"]);
  //     // return '';
  //   }
  // }

//热更新
  // await getFeedURL();
  String feedURL = '${Constant.baseUrlDev}/mes-biz/api/common/appVersion';
  // String feedURL = '${Constant.baseUrlFat}/hc-mes/api/app/version';
  // String feedURL = '${Constant.baseUrlPro}/hc-mes/api/app/version';
  // print('${Constant.baseUrlFat}/hc-mes/api/app/version');
  await autoUpdater.setFeedURL(feedURL);
  await autoUpdater.checkForUpdates();
  await autoUpdater.setScheduledCheckInterval(3600);

//初始化尺寸
  MediaKit.ensureInitialized();
  await windowManager.ensureInitialized();
  await LoginPrefs.init();
  WindowOptions windowOptions = const WindowOptions(size: Size(1920, 1280));
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // await windowManager.setTitleBarStyle(
    //   TitleBarStyle.hidden,
    // );
    // await windowManager.setSize(const Size(1920, 1080));
    // await windowManager.setMinimumSize(const Size(1920, 1080));
    // await windowManager.setMaximumSize(const Size(1920, 1080));
    // await windowManager.setFullScreen(true);
    // await windowManager.setPreventClose(true);
    await windowManager.show();
    await windowManager.focus();
  });

  // await Request.init();
  LoginPrefs.clearLogin();
  configLoading();

  runApp(const MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..indicatorSize = 50
    ..fontSize = 30
    ..displayDuration = const Duration(milliseconds: 5000);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var token;

  void changeToken() {
    token = LoginPrefs.getToken();
    print('运行了change函数${token}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final userModel = Provider.of<UserModel>(context);
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserModel())],
      child: MaterialApp(
        title: 'hc_mes_app',
        theme: ThemeData(
          // fontFamily: 'Schyler',
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Color(0x472667FF);
                }
                if (states.contains(MaterialState.hovered)) {
                  return Color(0x472667FF);
                }
                return Color(0x472667FF);
              },
            ),
            trackColor: MaterialStateProperty.all(Colors.transparent), // 轨道颜色
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffC1D3FF)),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) {
            final userModel = context.read<UserModel>();
            return Consumer<UserModel>(
                builder: (context, counter, child) => (userModel.token != ''
                    ? userModel.info['processId'].isNotEmpty &&
                            userModel.info['positionId'].isNotEmpty
                        ? Home()
                        : PositionPage()
                    // : Home(changeToken: changeToken)
                    : Login()));

            // userModel.token != ''
            //     ? Home(changeToken: changeToken)
            //     : Login(changeToken: changeToken);
          },
        ),
        builder: EasyLoading.init(),
      ),
    );
  }
}

// class Login extends StatelessWidget {
//   const Login({super.key});

//   @override
//   Widget build(BuildContext context) {
//     TextEditingController username = TextEditingController();
//     TextEditingController password = TextEditingController();
//     return Scaffold(
//         body: Container(
//       alignment: Alignment.topCenter,
//       width: 1920,
//       height: 1080,
//       padding: const EdgeInsets.only(left: 57, right: 57),
//       decoration: const BoxDecoration(
//           image: DecorationImage(
//               image: AssetImage('images/login-bg.png'), fit: BoxFit.cover)),
//       child: Column(children: [
//         Container(
//             width: 1806,
//             height: 108,
//             decoration: const BoxDecoration(
//                 image: DecorationImage(
//               image: AssetImage('images/login-title.png'),
//             ))),
//         Center(
//           child: Container(
//               width: 530,
//               height: 502,
//               margin: const EdgeInsets.only(top: 178),
//               padding: const EdgeInsets.only(top: 50),
//               decoration: const BoxDecoration(
//                   image: DecorationImage(
//                 image: AssetImage('images/login-form-bg.png'),
//               )),
//               child: const Column(
//                 children: [
//                   Text(
//                     '欢迎登录',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 24,
//                         color: Color.fromARGB(255, 223, 232, 255)),
//                   ),
//                   Form(
//                       key: form,
//                       child: Column(
//                         children: [
//                           usernameInput(username),
//                           const SizedBox(
//                             height: 50,
//                           ),
//                           passwordInput(password),
//                         ],
//                       )),
//                 ],
//               )),
//         )
//       ]),
//     ));
//   }
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
