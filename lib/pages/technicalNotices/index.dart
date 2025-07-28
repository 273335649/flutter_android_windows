import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../common//dio_request.dart';
import '../../common/constant.dart';
import 'package:hc_mes_app/common/login_prefs.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:hc_mes_app/utils/init.dart';
import 'package:provider/provider.dart';
import 'package:hc_mes_app/pages/home/home.dart';

List dataList = [];

class TechnicalNotices extends StatefulWidget {
  const TechnicalNotices({super.key});

  @override
  State<TechnicalNotices> createState() => _TechnicalNoticesState();
}

class _TechnicalNoticesState extends State<TechnicalNotices> {
  late WebviewController _controller;
  int _targetIndex = 0; // 目标列表项的索引
  late final UserModel _userModel;
  @override
  void initState() {
    _userModel = Provider.of<UserModel>(context, listen: false);
    _controller = WebviewController();
    getList();
    initPlatformState();
    super.initState();
  }

  //登录鉴权
  Future zdLogin() async {
    var password = await encodeString('Hm123456*' //prod
        // 'abc123ABC*' //test
        );
    print('用户信息：${password}');
    var params = {
      // "userName": "humi001", //test
      "userName": "10003", //prod
      'password': password,
    };

    print('接口提交信息${params}');

    var response = await Request.post(
      "/rest/core/auth/login",
      data: params,
      baseUrl: Constant.zdUrl,
    );
    // print('接口返回数据111：${response}');
    if (response["state"]) {
      print('接口返回数据：${response["identitytoken"]}');
      LoginPrefs.saveIdentitytoken(response["identitytoken"]);
      return response["identitytoken"];
    } else {
      EasyLoading.showError(response["message"]);
      return '';
    }
  }

  Future<void> getUrl(fileName) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // String clientToken = await zdLogin();
    // print('clientId：${clientToken}');
    // print("fileName:$fileName");
    Map<String, dynamic> jsonMap = jsonDecode(fileName);
    var _fileName = jsonMap.keys.first;

    print("_fileName:$_fileName");
    // var params = {
    //   'fileName': fileName,
    //   // "bucket": 'zd-ipass-test',
    //   // "accessKey": 'bCQDlLS-d_oedUil78rnlRDJxXFQaq45ucY3P5Bx',
    //   // "secretKey": 'fQ0qxCo8Bn0nel0R7jywaY9wR4Vb9hPPpz6jsIZF',
    //   "bucket": 'hc-mes',
    //   "accessKey": 'zBj4f0g70p8cNO0Q6dP-Ul3l7fKhj7_sayruZC8I',
    //   "secretKey": 'jlmMVSxZbDtOhllWfOR0z4zrx6YYNZW69Dx9Fp_X',
    //   "identitytoken": clientToken
    // };
    var params = {"urlType": "getFile", "fileName": _fileName};
    print('接口提交信息${params}');

    var response = await Request.get(
      "/mes-admin/meta/column/getUploadInfo",
      params: params,
    );
    print('接口返回数据：${response}');
    await _controller.setBackgroundColor(Colors.white);
    await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    await _controller.loadUrl("${response['data']}");
    // await _controller.loadUrl(
    //     "https://obsak.langyagplat.com/help_doc/19%20%E5%AE%89%E5%BE%BD%E5%BA%B7%E4%BD%B3%E5%B7%A5%E4%B8%9A%E4%BA%92%E8%81%94%E7%BD%91%E5%B9%B3%E5%8F%B0%E4%BC%81%E4%B8%9A%E8%AE%A4%E8%AF%81%E6%93%8D%E4%BD%9C%E6%89%8B%E5%86%8C.pdf");

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> changeStatus(publishId) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print(infoData);
    var params = {
      'publishId': publishId,
      'userId': infoData['employeeId'],
      'userName': infoData['employeeName']
    };

    var response =
        await Request.post('/mes-biz/api/tecnotice/read', data: params);
    print('已读：${response}');
    if (response['success']) {
      getList();
      _userModel.getTecnoticeCount();
    }
  }

  // Optionally initialize the webview environment using
  Future<void> initPlatformState() async {
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    // try {
    //   await _controller.initialize();
    //   await _controller.setBackgroundColor(Colors.white);
    //   await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    //   await _controller.loadUrl(
    //       "https://obsak.langyagplat.com/help_doc/19%20%E5%AE%89%E5%BE%BD%E5%BA%B7%E4%BD%B3%E5%B7%A5%E4%B8%9A%E4%BA%92%E8%81%94%E7%BD%91%E5%B9%B3%E5%8F%B0%E4%BC%81%E4%B8%9A%E8%AE%A4%E8%AF%81%E6%93%8D%E4%BD%9C%E6%89%8B%E5%86%8C.pdf");

    //   if (!mounted) return;
    //   setState(() {});
    // } catch (e) {}
    try {
      await _controller.initialize();
      // await getUrl('28612d58b0d5c0ab32a9.pdf');
      await getUrl(dataList[0]['url']);
      if (dataList[0]['readStatus'] == 0) {
        changeStatus(dataList[0]['publishId']);
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {}
  }

  Future<void> getList() async {
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${finalData}');
    var response =
        await Request.get('/mes-biz/api/tecnotice/listByStationId', params: {
      'stationId': finalData['stationId'],
    });
    print('技术通知列表：${response}');
    dataList = response['data'];
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Flex(direction: Axis.horizontal, children: [
        Expanded(
          flex: 1,
          child: Container(
            width: 140,
            height: 700,
            child: ListView(
                children: List.generate(
              dataList.length,
              (index) => Container(
                  margin: EdgeInsets.only(bottom: 15, right: 8),
                  padding: EdgeInsets.only(right: 2, top: 2),
                  width: 140,
                  height: 87,
                  decoration: BoxDecoration(
                    color: _targetIndex == index
                        ? Color(0xff004dc5)
                        : Color.fromARGB(23, 31, 94, 255),
                    border: Border.all(color: Color(0xff0057d9), width: 1),
                  ),
                  child: Badge(
                    // label: Text('3'),
                    // alignment: Alignment.topLeft,
                    // offset: Offset(200, 200),
                    smallSize: 15,
                    largeSize: 15,
                    isLabelVisible: dataList[index]['readStatus'] == 0,
                    child: InkWell(
                      onTap: () {
                        print('文件地址：${dataList[index]['url']}');
                        setState(() {
                          _targetIndex = index;
                          getUrl(dataList[index]['url']);
                          if (dataList[index]['readStatus'] == 0) {
                            changeStatus(dataList[index]['publishId']);
                          }
                        });
                        // _controller.loadUrl(dataList[index]['url']);
                        // _controller.loadUrl(
                        // _scrollToItem(index);
                      },
                      child: Center(
                          // padding: EdgeInsets.all(10),
                          child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          dataList[index]['title'].toString(),
                          style: TextStyle(
                              fontSize: 22,
                              color: Color.fromARGB(230, 255, 255, 255)),
                        ),
                      )),
                    ),
                  )),
            )),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
              height: 700,
              // width: 500,
              color: Colors.white,
              child: Webview(_controller)),
        ),
      ]),
    );
  }
}
