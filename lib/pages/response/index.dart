import 'package:flutter/material.dart';
import '../../common/login_prefs.dart';
import '../../widget/childLogin.dart';
import 'package:provider/provider.dart';
import '../home/home.dart';
import 'dart:convert';
import '../../common//dio_request.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import '../leftCard/index.dart';

class Response extends StatefulWidget {
  const Response({super.key});

  @override
  State<Response> createState() => _ResponseState();
}

class _ResponseState extends State<Response> {
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    // token = LoginPrefs.getChildToken();

    return userModel.childToken != ''
        ?
        // Container(
        //     width: 1340,
        //     height: 780,
        //     // padding: const EdgeInsets.all(20),
        //     // color: Colors.red,
        //     child: ResponseContent(token: token, removeToken: removeToken),
        //   )

        ResponseContent()
        : ChildLogin(title: '欢迎使用安灯响应功能');
  }
}

List colorsList = [
  0x8FDC9E00,
  0x4DFF0000,
  0x6600DEEC,
  0x00000000,
  0x4DFF0000,
];
List statusList = [
  '呼叫中',
  '响应超时',
  '响应',
  '完结',
  '完结超时',
];

class ResponseContent extends StatefulWidget {
  const ResponseContent({
    super.key,
  });

  @override
  State<ResponseContent> createState() => _ResponseContentState();
}

class _ResponseContentState extends State<ResponseContent> {
  late final ScrollController _scrollController = ScrollController();
  TextEditingController handleResult = TextEditingController();
  FocusNode handleResultfocusNode = FocusNode();
  List dataList = [];
  var arrList = [0];
  var sum = 0;
  var infoChildData;
  late final UserModel _userModel;
  List<Widget> defectCodeListToWidgets(List<dynamic> defectCodeList, context) {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    return defectCodeList.map((subitem) {
      return InkWell(
        onTap: () {
          handleResult.clear();
          print('用户信息:${infoData}');
          // updateUi();
          print(subitem);
          if (subitem['respStatus'].toString() != '2' &&
              subitem['respStatus'].toString() != '4') {
            showDialogFunction(context, {
              'width': 860.0,
              'height': 400.0,
              'title': '呼叫响应',
              'okText': '响应',
              'onSubmit': () {
                return submitDetails(subitem);
              },
              'content': Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '产线:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                infoData['lineName'],
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '呼叫人:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                subitem['currentCallPersonName'] ?? '',
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '呼叫岗位:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                subitem['stationName'] ?? '',
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '呼叫时间:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                subitem['currentCallTime'] ?? '',
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '呼叫状态:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: Color(
                                        colorsList[subitem['respStatus']]),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    statusList[subitem['respStatus']],
                                    style: TextStyle(
                                      color: Color(0xffC1D3FF),
                                      fontSize: 24,
                                    ),
                                  )
                                ],
                              )),
                        )
                      ],
                    ),

                    // Text(
                    //   '发起后需等待响应和事件处理',
                    //   style: TextStyle(
                    //       color: Color.fromARGB(90, 255, 255, 255),
                    //       fontSize: 24),
                    // ),
                  ])
            });
          } else {
            showDialogFunction(context, {
              'width': 860.0,
              'height': 600.0,
              'title': '呼叫完结',
              'okText': '完结',
              'onSubmit': () {
                return finishDetails(subitem);
              },
              'content': Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '产线:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                infoData['lineName'],
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '呼叫人:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                subitem['currentCallPersonName'] ?? '',
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '呼叫岗位:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                subitem['stationName'] ?? '',
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '呼叫时间:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                subitem['currentCallTime'] ?? '',
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '呼叫状态:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: Color(
                                        colorsList[subitem['respStatus']]),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    statusList[subitem['respStatus']],
                                    style: TextStyle(
                                      color: Color(0xffC1D3FF),
                                      fontSize: 24,
                                    ),
                                  )
                                ],
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '响应人:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                subitem['currentResponsePersonName'] ?? '',
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '响应时间:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                              color: Color(0x661F5EFF),
                              height: 64,
                              padding: EdgeInsets.only(left: 24, top: 17),
                              child: Text(
                                subitem['currentResponseTime'] ?? '',
                                style: TextStyle(
                                  color: Color(0xffC1D3FF),
                                  fontSize: 24,
                                ),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Color(0x331F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(left: 24, top: 17),
                            child: const Text(
                              '处理措施:',
                              style: TextStyle(
                                color: Color(0xffC1D3FF),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            color: Color(0x661F5EFF),
                            height: 64,
                            padding: EdgeInsets.only(top: 5),
                            child: inputWidget(
                                handleResult, handleResultfocusNode),
                          ),
                        )
                      ],
                    ),
                  ])
            });
            // EasyLoading.showError('此事件已被呼叫，请勿重复呼叫');
          }
          // selectDefect['id'] = subitem['id'];
        },
        highlightColor: Colors.transparent, // 透明色
        splashColor: Colors.transparent,
        child: Container(
          height: 88,
          width: 254,
          // color: Colors.red,
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 12),
          decoration: BoxDecoration(
              color: Color(colorsList[subitem['respStatus'] ?? 3]),
              border: Border.all(
                  color: Color((subitem['respStatus'] ?? 3) == 3
                      ? 0xff0057d9
                      : colorsList[subitem['respStatus'] ?? 3]),
                  width: 1)),
          child: (Text(subitem['name'],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ))),
        ),
      );
    }).toList();
  }

  //安灯响应
  Future<bool> submitDetails(value) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // var infoChildData = jsonDecode(LoginPrefs.getChildUserInfo() ?? '');
    print('用户信息：${infoData}');

    var params = {
      'eventId': value['id'],
      'lineCode': infoData['lineCode'],
      'lineName': infoData['lineName'],
      'lineId': infoData['lineId'],
      'operatorId': infoChildData['id'],
      'responseEventId': value['recordId'],
    };
    print('接口提交信息${params}');

    var response = await Request.post(
        "/mes-biz/api/mes/client/andon/andonResponse",
        data: params,
        isChildToken: true);
    if (response["success"]) {
      var resData = response["data"];

      print(response["data"]);
      print(resData);
      // dataList = resData;
      EasyLoading.showSuccess(response["message"]);
      setState(() {});
      return true;
    } else {
      EasyLoading.showError(response["message"]);
      return false;
    }
  }

  //安灯完结
  Future<bool> finishDetails(value) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    var infoChildData = jsonDecode(LoginPrefs.getChildUserInfo() ?? '');
    print('用户信息：${infoData}');

    var params = {
      'eventId': value['id'],
      'lineCode': infoData['lineCode'],
      'lineName': infoData['lineName'],
      'lineId': infoData['lineId'],
      'operatorId': infoChildData['id'],
      'responseEventId': value['recordId'],
      'handleResult': handleResult.text,
    };
    print('接口提交信息${params}');

    var response = await Request.post(
        "/mes-biz/api/mes/client/andon/andonFinish",
        data: params,
        isChildToken: true);
    if (response["success"]) {
      var resData = response["data"];

      print(response["data"]);
      print(resData);
      // dataList = resData;
      EasyLoading.showSuccess(response["message"]);
      // handleResult.clear();
      setState(() {});
      return true;
    } else {
      EasyLoading.showError(response["message"]);
      return false;
    }
  }

  //获取页面详情数据
  Future<void> getDetails(isShow) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    var infochildData = jsonDecode(LoginPrefs.getChildUserInfo() ?? '');
    print('用户信息：${infochildData}');

    var params = {
      'lineId': infoData['lineId'],
      'callEmployeeId': infochildData['id'],
      'isAll': false
      // 'barCode': username.text,
    };
    print('接口提交信息${params}');

    var response = await Request.get(
        "/mes-biz/api/mes/client/andon/getAndonType",
        params: params,
        isShow: isShow,
        isChildToken: true);
    if (response["success"]) {
      var resData = response["data"]['andonTypeList'] ?? {};
      dataList = resData;

      if (isShow) {
        print(response["data"]);
        print(resData);
        for (var i = 0; i < dataList.length; i++) {
          int length = dataList[i]['andonEventList'].length;

          if (length == 0) {
            sum += 88;
          } else if (length <= 4) {
            sum += 176;
          } else {
            sum += (88 + (length.toDouble() / 4).ceil().toInt() * 112 - 24);
          }
          arrList.add(sum);
        }
      }
    } else {
      EasyLoading.showError(response["message"]);
      _userModel.setChildToken('');
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _userModel = Provider.of<UserModel>(context, listen: false);

    super.initState();
    // 添加监听器
    _scrollController.addListener(() {
      setState(() {
        for (var i = 0; i < arrList.length; i++) {
          if (arrList[i] > _scrollController.position.pixels) {
            _targetIndex = i - 1;
            break;
          }
        }
        // _targetIndex =
        //     (_scrollController.position.pixels / 176).round().toInt() as int;
      });
    });
    getDetails(true);

    // startTimer();
  }

  @override
  bool get mounted {
    print('12354545${LoginPrefs.getChildUserInfo()}');
    infoChildData = jsonDecode(LoginPrefs.getChildUserInfo() ?? '');
    // TODO: implement mounted
    _userModel.setAndonCount(0);
    return super.mounted;
  }

  var myTimer;

  void startTimer() {
    // 创建周期性定时器，每500毫秒执行一次
    myTimer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      await getDetails(false);
    });
  }

  void stopTimer() {
    // 取消定时器
    if (myTimer != null) {
      myTimer.cancel();
      myTimer = null;
    }
  }

  int _targetIndex = 0; // 目标列表项的索引
  // 滚动到指定索引的方法
  void _scrollToItem(int index) {
    _scrollController.animateTo(
      arrList[index].toDouble(), // 0.0 是对齐方式，表示顶部对齐
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void deactivate() {
    // 移除监听器
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    stopTimer();
    super.deactivate();
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
                width: 140,
                height: 87,
                decoration: BoxDecoration(
                  color: _targetIndex == index
                      ? Color(0xff004dc5)
                      : Color.fromARGB(23, 31, 94, 255),
                  border: Border.all(color: Color(0xff0057d9), width: 1),
                ),
                child: InkWell(
                  onTap: () {
                    print('滚动到${index}');
                    _scrollToItem(index);
                  },
                  child: Container(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        dataList[index]['name'].toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 22,
                            color: Color.fromARGB(230, 255, 255, 255)),
                      )),
                ),
              ),
            )),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            padding: EdgeInsets.all(30),
            height: 700,
            decoration: BoxDecoration(
                border: Border.all(color: Color(0xff0057d9), width: 1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Container(
                        //   alignment: Alignment.center,
                        //   width: 60,
                        //   height: 30,
                        //   decoration: BoxDecoration(
                        //       color: Color(0x00000000),
                        //       border: Border.all(
                        //           color: Color(0xff0057d9), width: 1)),
                        //   child: Text(
                        //     '完结',
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   width: 20,
                        // ),
                        Container(
                          alignment: Alignment.center,
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Color(0x6600DEEC),
                              border: Border.all(
                                  color: Color(0x6600DEEC), width: 1)),
                          child: Text(
                            '响应中',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Color(0x8FDC9E00),
                              border: Border.all(
                                  color: Color(0x8FDC9E00), width: 1)),
                          child: Text(
                            '呼叫中',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                              color: const Color(0x4DFF0000),
                              border: Border.all(
                                  color: const Color(0x4DFF0000), width: 1)),
                          child: const Text(
                            '超时',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${userModel.childInfo['name'].toString()}  |',
                          style: TextStyle(
                              color: Color.fromARGB(153, 255, 255, 255)),
                        ),
                        TextButton(
                          onPressed: () {
                            userModel.setChildToken('');
                            LoginPrefs.removeChildToken();
                            LoginPrefs.saveChildUserInfo('{}');
                          },
                          child: Text('退出登录',
                              style: TextStyle(
                                  color: Color.fromARGB(153, 255, 255, 255))),
                          style: ButtonStyle(
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  return Colors.transparent;
                                },
                              ),
                              textStyle: MaterialStatePropertyAll(
                                  TextStyle(color: Colors.white))),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  flex: 1,
                  child: ListView(
                    controller: _scrollController,
                    children: List.generate(
                        dataList.length,
                        (index) => Container(
                              width: 140,
                              // height: 40,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 18,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xff0057d9),
                                                  width: 1)),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          dataList[index]['name'],
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Wrap(
                                        spacing: 10.0, // 主轴(水平)方向间距
                                        runSpacing: 24.0, // 纵轴（垂直）方向间距
                                        alignment:
                                            WrapAlignment.start, //沿主轴方向居中
                                        children: defectCodeListToWidgets(
                                            dataList[index]['andonEventList'] ??
                                                [],
                                            context)),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ]),
                            )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

OutlineInputBorder _outlineInputBorder = const OutlineInputBorder(
  gapPadding: 0,
  borderSide: BorderSide(
    color: Color(0x661F5EFF),
  ),
);

Widget inputWidget(TextEditingController controller, focusNode) {
  return TextFormField(
    controller: controller,

    cursorColor: Colors.white,
    style: const TextStyle(
      color: Colors.white,
    ),
    onChanged: (value) async {
      print(value);
      if (value.length >= 50) {
        EasyLoading.showError('输入内容不可超过50个字');
      }
    },
    maxLength: 50,
    decoration: InputDecoration(
      counterText: '',
      filled: true,
      fillColor: Color(0x661F5EFF),
      // hintText: '请扫描或输入',
      hintStyle: const TextStyle(color: Color.fromARGB(153, 255, 255, 255)),
      border: _outlineInputBorder,
      focusedBorder: _outlineInputBorder,
      enabledBorder: _outlineInputBorder,
      disabledBorder: _outlineInputBorder,
      focusedErrorBorder: _outlineInputBorder,
      errorBorder: _outlineInputBorder,
    ),
    // validator: (value) {
    //   if (value!.isEmpty) {
    //     return '用户名不能为空';
    //   }
    //   return null;
    // },
    focusNode: focusNode,
    onSaved: (v) => controller.text = v!,
  );
}
