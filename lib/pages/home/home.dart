import 'dart:convert';

import 'package:flutter/material.dart';
import '../header/header.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:common_utils/common_utils.dart';
import '../../common/login_prefs.dart';
import '../productionOrder/index.dart';
import '../demo/index.dart';
import '../manualMachining/index.dart';
import '../processInquiry/index.dart';
import '../technicalNotices/index.dart';
import '../unqualified/index.dart';
import '../review/index.dart';
import '../call/index.dart';
import '../response/index.dart';
import '../maintenance/index.dart';
import '../leftCard/index.dart';
import '../log/index.dart';
import 'package:yaml/yaml.dart';
import 'dart:io';
import '../../component/webview_component.dart';

List btnImgList = [
  'images/btn-gongdan',
  'images/btn-jijia',
  'images/btn-gongyi',
  'images/btn-jitong',
  'images/btn-buhege',
  'images/btn-pingshen',
  'images/btn-hujiao',
  'images/btn-xiangying',
  'images/btn-weibao',
  'images/btn-tuichu',
];
//表格文字样式
TextStyle _labelTextStyle = const TextStyle(
  fontSize: 20,
  color: Color(0xffffffff),
);

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '';
  String versionNum = '';

  Future<String> getVersionFromPubspec() async {
    try {
      // 读取 pubspec.yaml 文件
      final file = File('pubspec.yaml');
      final content = await file.readAsString();

      // 解析 YAML 内容
      final pubspec = loadYaml(content);

      // 访问版本号
      final version = pubspec['version'] as String;
      print('version$version');
      setState(() {
        versionNum = version;
      });
      return version;
    } on Exception catch (e) {
      print('Error reading version from pubspec.yaml: $e');
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    getVersionFromPubspec();
    // 初始化数据
    print('登录名${LoginPrefs.getUserInfo()}');
    // userName = LoginPrefs.getUserInfo()['username'];
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController username = TextEditingController();
    final userinfo = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    final userModel = Provider.of<UserModel>(context);
    print('更新');
    return Scaffold(
      body: Stack(
        children: [
          Container(width: 1920, height: 1080, color: const Color(0xff001030)),

          HeaderMenu(),

          //左侧生产报工
          // LeftCard(),
          //右侧内容组件
          Container(
            // width: 1340,
            height: 844,
            margin: const EdgeInsets.only(left: 0, top: 180),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/table-card-bgc.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Pages(),
          ),

          Container(
            height: 26,
            width: 1860,
            // color: Colors.red,
            margin: const EdgeInsets.only(left: 30, top: 1025),
            child: Row(
              children: [
                TimeWidget(),
                Text(
                  ' |   登录人：${userinfo['username']}   |   产线：${userinfo['lineOrgPath']}   ${userinfo['lineName']}   岗位：${userModel.info['positionId']?['name']}   当前工序：${userinfo['processCode']}-${userinfo['processName']}   当前设备：${userinfo['equipmentName']}  ',
                  style: TextStyle(color: Color(0xFFF3a6fce), fontSize: 18),
                ),
                Text(
                  '当前版本：${versionNum}',
                  style: TextStyle(color: Color(0xFFF3a6fce), fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeWidget extends StatefulWidget {
  const TimeWidget({super.key});

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  String _currentTime = '';
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _updateTime();
    // 每秒更新一次时间
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    DateTime now = DateTime.now();
    String formattedTime = DateUtil.formatDate(
      now,
      format: "yyyy-MM-dd   HH:mm:ss",
    );

    setState(() {
      _currentTime = formattedTime;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 在widget销毁时取消定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: TextStyle(color: Color(0xFFF3a6fce), fontSize: 18),
    );
  }
}

List arr = [
  {
    'title': '工单',
    // 'widget': ProductionOrder(),
    'widget': const WebViewComponent(initialUrl: 'http://190.75.16.210:30004/'),
  },
  {'title': '人工机加', 'widget': ManualMachining()},
  {'title': '工艺查询', 'widget': ProcessInquiry()},
  {'title': '技术通知', 'widget': TechnicalNotices()},
  {'title': '返工返修入库', 'widget': Unqualified()},
  {'title': '不合格评审', 'widget': Review()},
  {'title': '安灯呼叫', 'widget': Call()},
  {'title': '安灯响应', 'widget': Response()},
  {'title': '设备维保', 'widget': Maintenance()},
  {'title': '日志清单', 'widget': Log()},
  {'title': 'demo', 'widget': Demo()},
];

class UserModel extends ChangeNotifier {
  String token = '';
  String childToken = '';
  int activeIndex = 0;
  int andonCount = 0;

  Map info = {'processId': '', 'positionId': ''};
  Map barcodeinfo = {};
  Map childInfo = {'name': ''};

  void setInfo(Map info) {
    this.info = info;
    notifyListeners();
  }

  void setBarcodeinfo(Map info) {
    barcodeinfo = info;
    notifyListeners();
  }

  void setChildInfo(Map childInfo) {
    this.childInfo = childInfo;
    notifyListeners();
  }

  void setToken(String token) {
    this.token = token;
    notifyListeners();
  }

  void setChildToken(String token) {
    childToken = token;
    notifyListeners();
  }
  //存储跨组件调用方法

  var fun;
  var begin;
  var focusFn;
  var getTecnoticeCountFn;
  var exportImageFn;
  //储存编辑图片函数
  void saveExportImageFn(fn) {
    exportImageFn = fn;

    // notifyListeners();
  }

  getExportImageFn() async {
    return await exportImageFn();

    // notifyListeners();
  }

  void saveTecnoticeCountFn(fn) {
    getTecnoticeCountFn = fn;

    // notifyListeners();
  }

  void getTecnoticeCount() {
    getTecnoticeCountFn();

    // notifyListeners();
  }

  void savefocusFn(fn) {
    focusFn = fn;

    // notifyListeners();
  }

  void saveRefreshFn(fn) {
    fun = fn;

    // notifyListeners();
  }

  void saveBeginFn(fn) {
    begin = fn;

    // notifyListeners();
  }

  void refreshfocus() {
    focusFn();

    // notifyListeners();
  }

  void refreshWeight() {
    fun();

    // notifyListeners();
  }

  void autoBegin() {
    print('999999${begin}');
    begin();

    // notifyListeners();
  }

  void setAndonCount(int index) {
    andonCount = index;
    notifyListeners();
  }

  void setActiveIndex(int index) {
    if (index != activeIndex) {
      childToken = '';
      childInfo = {'name': ''};
    }
    activeIndex = index;
    notifyListeners();
    print(index); // 当状态改变时，通知所有监听者
  }

  void clear() {
    print('clear');
    childToken = '';
    activeIndex = 0;
    token = '';
    info = {'processId': '', 'positionId': ''};
    childInfo = {'name': ''};
    barcodeinfo = {};
    notifyListeners();
  }
}

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return Column(
      children: [
        Container(
          width: 1336,
          height: 64,
          padding: const EdgeInsets.only(left: 56, top: 8),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/table-card-title.png'),
            ),
          ),
          child: Text(
            '${arr[userModel.activeIndex]['title']} ',
            style: TextStyle(
              fontSize: 32,
              color: Color(0xffffffff),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        arr[userModel.activeIndex]['widget'],
      ],
    );
  }
}
