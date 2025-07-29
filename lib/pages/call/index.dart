import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../common//dio_request.dart';
import '../../common/login_prefs.dart';
import 'dart:convert';

import 'dart:math';
import '../leftCard/index.dart';
import 'dart:async';

List colorsList = [
  0x8FDC9E00,
  0x4DFF0000,
  0x6600DEEC,
  0x00000000,
  0x4DFF0000,
];

class Call extends StatefulWidget {
  const Call({super.key});

  @override
  State<Call> createState() => _TechnicalNoticesState();
}

class _TechnicalNoticesState extends State<Call> {
  late final ScrollController _scrollController = ScrollController();

  List dataList = [];
  var arrList = [0];
  var sum = 0;

  List<Widget> defectCodeListToWidgets(List<dynamic> defectCodeList, context) {
    return defectCodeList.map((subitem) {
      return InkWell(
        onTap: () {
          // updateUi();
          if (subitem['respStatus'] == null || subitem['respStatus'] == 3) {
            showDialogFunction(context, {
              'width': 500.0,
              'height': 150.0,
              'title': '确认提示',
              'onSubmit': () {
                return submitDetails(subitem['id']);
              },
              'content': Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '是否确定要发起${subitem['name']}事件的呼叫？发起后需等待响应和事件处理',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    // Text(
                    //   '发起后需等待响应和事件处理',
                    //   style: TextStyle(
                    //       color: Color.fromARGB(90, 255, 255, 255),
                    //       fontSize: 24),
                    // ),
                  ])
            });
            // print(subitem);
          } else {
            showDialogFunction(context, {
              'width': 500.0,
              'height': 150.0,
              'title': '确认提示',
              'onSubmit': () {
                return true;
              },
              'okText': '确定',
              'content': Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '此事件已被呼叫，请勿重复呼叫',
                      style: TextStyle(color: Colors.white, fontSize: 24),
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

  //安灯呼叫
  Future<bool> submitDetails(id) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // print('用户信息：${infoData}');

    var params = {
      'eventId': id,
      'lineCode': infoData['lineCode'],
      'lineName': infoData['lineName'],
      'lineId': infoData['lineId'],
      'operatorId': infoData['employeeId'],
      'stationId': infoData['stationId'],
      'stationName': infoData['stationName'],
    };
    // print('接口提交信息${params}');

    var response = await Request.post("/mes-biz/api/mes/client/andon/andonCall",
        data: params);
    if (response["success"]) {
      var resData = response["data"];

      // print(response["data"]);
      // print(resData);
      // dataList = resData;
      EasyLoading.showSuccess(response["message"]);
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

    var params = {
      'lineId': infoData['lineId'],
      'callEmployeeId': infoData['employeeId'],
      'isAll': true
      // 'barCode': username.text,
    };

    var response =
        await Request.get("/mes-biz/api/mes/client/andon/getAndonType",
            params: {
              'lineId': infoData['lineId'],
              'callEmployeeId': infoData['employeeId'],
              'isAll': true
            },
            isShow: isShow);
    if (response["success"]) {
      var resData = response["data"]['andonTypeList'] ?? {};

      dataList = resData;

      if (isShow) {
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
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
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
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                    alignment: Alignment.center,
                    width: 60,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Color(0x00000000),
                        border: Border.all(color: Color(0xff0057d9), width: 1)),
                    child: Text(
                      '完结',
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
                        color: Color(0x6600DEEC),
                        border: Border.all(color: Color(0x6600DEEC), width: 1)),
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
                        border: Border.all(color: Color(0x8FDC9E00), width: 1)),
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
                ]
                    // [
                    //   Container(
                    //     child: Text(
                    //       '响应',
                    //       style: TextStyle(color: Colors.red),
                    //     ),
                    //   )
                    // ],
                    ),
                const SizedBox(
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
                                            dataList[index]['andonEventList'],
                                            context)

                                        //  [
                                        //   InkWell(
                                        //     onTap: () {
                                        //       print('技通');
                                        //     },
                                        //     highlightColor:
                                        //         Colors.transparent, // 透明色
                                        //     splashColor: Colors.transparent,
                                        //     child: Container(
                                        //       height: 88,
                                        //       width: 254,
                                        //       alignment: Alignment.center,
                                        //       padding: EdgeInsets.only(
                                        //           left: 40,
                                        //           right: 40,
                                        //           top: 12,
                                        //           bottom: 12),
                                        //       decoration: BoxDecoration(
                                        //           border: Border.all(
                                        //               color: Color(0xff0057d9),
                                        //               width: 1)),
                                        //       child: (Text(
                                        //           '响应中事件响应中事件响应中事件响应中事件响应中事件123455',
                                        //           overflow: TextOverflow.ellipsis,
                                        //           maxLines: 2,
                                        //           style: TextStyle(
                                        //             fontSize: 22,
                                        //             color: Colors.white,
                                        //           ))),
                                        //     ),
                                        //   ),
                                        // ]
                                        ),
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
