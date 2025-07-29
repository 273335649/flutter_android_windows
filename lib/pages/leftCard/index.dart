import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hc_mes_app/main.dart';

import '../../common/login_prefs.dart';
import 'package:provider/provider.dart';

import '../manualMachining/index.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../common//dio_request.dart';
import '../home/home.dart';

import "package:dart_amqp/dart_amqp.dart";

import 'package:hc_mes_app/utils/init.dart';

import '../../common/constant.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_painter/image_painter.dart';
import 'package:http_parser/src/media_type.dart';
import 'dart:async';
import '../productionOrder/index.dart';

//表格文字样式
TextStyle _labelTextStyle =
    const TextStyle(fontSize: 20, color: Color(0xffffffff));

class LeftCard extends StatefulWidget {
  const LeftCard({super.key});

  @override
  State<LeftCard> createState() => _LeftCardState();
}

class _LeftCardState extends State<LeftCard> {
  TextEditingController username = TextEditingController();
  FocusNode usernamefocusNode = FocusNode();
  Map detailData = {};
  String barCode = '';
  late Client client;
  var myTimer;

  void startTimer() {
    // 创建周期性定时器，每500毫秒执行一次
    myTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      // print(_userModel.activeIndex);
      if (_userModel.activeIndex <= 1) {
        usernamefocusNode.requestFocus();
      }
    });
  }

  void stopTimer() {
    // 取消定时器
    if (myTimer != null) {
      myTimer.cancel();
      myTimer = null;
    }
  }

  //获取页面详情数据
  Future getDetails() async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${infoData}');

    var params = {
      'stationName': infoData['stationName'],
      'stationId': infoData['stationId'],
      'processId': infoData['processId'],
      'processName': infoData['processName'],
      'processCode': infoData['processCode'],
      'lineName': infoData['lineName'],
      'lineId': infoData['lineId'],
      'lineCode': infoData['lineCode'],
      'employeeId': infoData['employeeId'],
      'employeeNo': infoData['employeeNo'],
      'employeeName': infoData['employeeName'],
      'equipmentCode': infoData['equipmentCode'],
      'equipmentId': infoData['equipmentId'],
      'equipmentName': infoData['equipmentName'],
      'barCode': username.text,
    };
    print('接口提交信息${params}');

    var response = await Request.post("/mes-biz/api/mes/client/task/barcodeIn",
        data: params);
    if (response["success"]) {
      var resData = response["data"] ?? {};
      barCode = username.text;
      resData['barCode'] = username.text;
      detailData = resData;
      print(resData);
      var materialInfo = {
        'materialCode': resData['materialCode'],
        'materialId': resData['materialId'],
        'materialName': resData['materialName']
      };
      LoginPrefs.saveMaterialInfo(jsonEncode(materialInfo));

      username.clear();
      return resData;
    } else {
      EasyLoading.showError(response["message"]);
      print('错误错误！！！${response}');
      username.clear();
      return null;
    }
  }

  //提交合格，不合格，移交评审

  Future submitDetail(conclusion) async {
    print('接口调用');
    boolApi = true;
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${infoData}');
    var defectImgList;
    if (conclusion == 2) {
      defectImgList =
          pictureList.where((item) => item['select'] ?? false).map((item) {
        return {
          'attachmentName': item['attachmentName'],
          'attachmentUrl': item['url']
        };
      }).toList();
    }
    var params = {
      'stationName': infoData['stationName'],
      'stationId': infoData['stationId'],
      'processId': infoData['processId'],
      'processName': infoData['processName'],
      'processCode': infoData['processCode'],
      'lineName': infoData['lineName'],
      'lineId': infoData['lineId'],
      'lineCode': infoData['lineCode'],
      'employeeId': infoData['employeeId'],
      'employeeNo': infoData['employeeNo'],
      'employeeName': infoData['employeeName'],
      'equipmentCode': infoData['equipmentCode'],
      'equipmentId': infoData['equipmentId'],
      'equipmentName': infoData['equipmentName'],
      'barCode': barCode,
      'materialCode': detailData['materialCode'],
      'materialName': detailData['materialName'],
      'produceOrderNo': detailData['produceOrderNo'],
      'conclusion': conclusion,
      'defectId': conclusion == 2 ? selectDefect['id'] : null,
      'defectImgList': conclusion == 2 ? defectImgList : null
    };

    print('接口提交信息11111111111111111${params}');

    var response = await Request.post(
        "/mes-biz/api/mes/client/task/reportUnqualified",
        data: params);

    boolApi = false;
    if (response["success"]) {
      // var resData = response["data"] ?? {};

      EasyLoading.showSuccess(response["message"]);
      print(response);
      detailData = {};
      barCode = '';
      username.clear();
      selectDefect = {};
      setState(() {});
      usernamefocusNode.requestFocus();
      _userModel.refreshWeight();
      return true;
    } else {
      EasyLoading.showError(response["message"]);
      usernamefocusNode.requestFocus();
      return false;
    }
  }

  Future autoGetDetails() async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    var autoInfoData = jsonDecode(LoginPrefs.getAutoUserInfo() ?? '');
    print('用户信息：${autoInfoData}');

    var params = {
      'stationName': autoInfoData['stationName'],
      'stationId': autoInfoData['stationId'],
      'processId': autoInfoData['processId'],
      'processName': autoInfoData['processName'],
      'processCode': autoInfoData['processCode'],
      'lineName': infoData['lineName'],
      'lineId': infoData['lineId'],
      'lineCode': infoData['lineCode'],
      'employeeId': infoData['employeeId'],
      'employeeNo': infoData['employeeNo'],
      'employeeName': infoData['employeeName'],
      'equipmentCode': autoInfoData['equipmentCode'],
      'equipmentId': autoInfoData['equipmentId'],
      'equipmentName': autoInfoData['equipmentName'],
      'barCode': username.text,
    };
    print('自动接口提交信息${params}');

    var response = await Request.post("/mes-biz/api/mes/client/task/barcodeIn",
        data: params);
    if (response["success"]) {
      var resData = response["data"] ?? {};
      barCode = username.text;
      resData['barCode'] = username.text;
      detailData = resData;
      print(resData);
      username.clear();
      return resData;
    } else {
      EasyLoading.showError(response["message"]);
      print('错误错误！！！${response}');
      username.clear();
      return null;
    }
  }

  Future autoSubmitDetail(conclusion) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    var autoInfoData = jsonDecode(LoginPrefs.getAutoUserInfo() ?? '');
    print('zidong用户信息：${autoInfoData}');

    var params = {
      'stationName': autoInfoData['stationName'],
      'stationId': autoInfoData['stationId'],
      'processId': autoInfoData['processId'],
      'processName': autoInfoData['processName'],
      'processCode': autoInfoData['processCode'],
      'lineName': infoData['lineName'],
      'lineId': infoData['lineId'],
      'lineCode': infoData['lineCode'],
      'employeeId': infoData['employeeId'],
      'employeeNo': infoData['employeeNo'],
      'employeeName': infoData['employeeName'],
      'equipmentCode': autoInfoData['equipmentCode'],
      'equipmentId': autoInfoData['equipmentId'],
      'equipmentName': autoInfoData['equipmentName'],
      'barCode': barCode,
      'materialCode': detailData['materialCode'],
      'materialName': detailData['materialName'],
      'produceOrderNo': detailData['produceOrderNo'],
      'conclusion': conclusion,
      'defectId': conclusion == 2 ? selectDefect['id'] : null
    };
    print('接口提交信息${params}');

    var response = await Request.post(
        "/mes-biz/api/mes/client/task/reportUnqualified",
        data: params);
    if (response["success"]) {
      // var resData = response["data"] ?? {};

      EasyLoading.showSuccess(response["message"]);
      print(response);
      detailData = {};
      barCode = '';
      username.clear();
      selectDefect = {};
      setState(() {});
      return true;
    } else {
      EasyLoading.showError(response["message"]);
      return false;
    }
  }

  // Future initmq() async {
  //   var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
  //   var autoinfoData = jsonDecode(LoginPrefs.getAutoUserInfo() ?? '');
  //   print("QU_MES2C_${infoData['lineId']}_${autoinfoData['processId']}");
  //   ConnectionSettings settings = ConnectionSettings(
  //       host: "172.16.201.62", //生产
  //       // host: "192.168.10.112", //测试
  //       virtualHost: '/hc_mes',
  //       authProvider:
  //           PlainAuthenticator("hmmquser", "PJexCWZ8PjxG2kMax2NM")); //生产
  //   // authProvider: PlainAuthenticator("root", "iFmxUasPV7U4fCBs")); //测试
  //   client = Client(settings: settings);
  //   Channel channel = await client.channel();

  //   Exchange exchange = await channel.exchange(
  //       "EX_MES2CLIENT", durable: true, ExchangeType.FANOUT);

  //   exchange.bindQueueConsumer(
  //       "QU_MES2C_${infoData['lineId']}_${autoinfoData['processId']}_prod",
  //       ['']);
  //   Queue queue = await channel.queue(
  //       "QU_MES2C_${infoData['lineId']}_${autoinfoData['processId']}_prod");
  //   var consumer = await queue.consume();
  //   consumer.listen((
  //     AmqpMessage message,
  //   ) async {
  //     print(" [x] Received string: ${message.payloadAsString}");
  //     print("scx:${infoData['lineCode']} gwh:${infoData['stationCode']}");
  //     var response = message.payloadAsJson;
  //     print('mq接受：${response['engineNo']}');
  //     // username.text = '123';
  //     if (response['scx'] == infoData['lineCode'] &&
  //         response['gwh'] == autoinfoData['stationCode'] &&
  //         response['ishege'] == 'TRUE') {
  //       username.value = username.value.copyWith(
  //         text: response['engineNo'],
  //       );
  //       var res = await autoGetDetails();
  //       print('自动查询结果：${res}');
  //       if (res != null) {
  //         await autoSubmitDetail(1);
  //       }
  //     }

  //     // // Or unserialize to json
  //     // print(" [x] Received json: ${message.payloadAsJson}");

  //     // // Or just get the raw data as a Uint8List
  //     // print(" [x] Received raw: ${message.payload}");
  //   });
  // }

  late final UserModel _userModel;

  List processList = [];
  var processSelect = {}; // 目标列表项的索引
  var positionSelect = {}; // 目标列表项的索引
  var equSelect = {}; // 目标列表项的索引
  Future<void> getPeocessList() async {
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');

    print(finalData['mac']);
    var processResponse = await Request.get(
        // "/mes-biz/api/mes/client/user/queryProcessByLine",
        // params: {'orgId': finalData['orgId']}
        "/mes-biz/api/mes/client/user/queryStationByMac",
        params: {'mac': finalData['mac']});
    if (processResponse["success"]) {
      List resData = processResponse["data"] ?? [];
      print('查看接口数据 ${resData}');
      // if (resData.length > 0) {
      //   var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
      //   finalData['employeeId'] = resData[0]['empId'];
      //   LoginPrefs.saveUserInfo(jsonEncode(finalData));
      // }
      processList = resData
          .map((e) => ({
                'id': e['stationId'],
                'name': e['stationName'],
                'code': e['stationCode'],
                'processid': e['processCellId'],
                'processname': e['processCellName'],
                'processcode': e['processCellCode'],
              }))
          .toList();

      setState(() {});
    } else {
      EasyLoading.showError('${processResponse['message']}');
    }
  }

  Future<void> getPositionList() async {
    var response = await Request.get(
        "/mes-biz/api/mes/client/user/queryStationByProcess",
        params: {
          "processId": processSelect['id'],
        });
    var resData = response["data"] ?? {};
    // // print('12345${response}');
    positionSelect['id'] = resData[0]['id']!;
    positionSelect['name'] = resData[0]['name']!;
    positionSelect['code'] = resData[0]['code']!;

    setState(() {
      print('选择的岗位${positionSelect}');
    });
  }

  Future<void> getEquipmentList() async {
    var response = await Request.post("/mes-eam/equipment/page",
        data: {"size": 500, 'current': 1, 'positionId': positionSelect['id']});

    if (response["success"]) {
      var resData = response["data"]['records'] ?? [];
      // // print('12345${response}');
      if (resData.length > 0) {
        equSelect['id'] = resData[0]['id']!;
        equSelect['name'] = resData[0]['name']!;
        equSelect['code'] = resData[0]['code']!;
        setState(() {
          print('选择的设备${equSelect}');
        });
      } else {
        boolApi = false;
      }
    } else {
      print('选择的设备');
      EasyLoading.showError('${response['message']}');
    }
  }

  Future<void> queryLineByStation() async {
    var response = await Request.get(
        "/mes-biz/api/mes/client/user/queryLineByStation",
        params: {
          "orgId": positionSelect['id'],
        });
    var resData = response["data"] ?? {};
    // print('12345${resData}');
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    finalData['lineName'] = resData['name'];
    finalData['lineCode'] = resData['code'];
    finalData['lineId'] = resData['id'];
    finalData['lineOrgPath'] = resData['orgPath'];
    finalData['processId'] = processSelect['id'];
    finalData['processCode'] = processSelect['code'];
    finalData['processName'] = processSelect['name'];
    finalData['opMode'] = processSelect['opMode'];
    finalData['stationId'] = positionSelect['id'];
    finalData['stationCode'] = positionSelect['code'];
    finalData['stationName'] = positionSelect['name'];
    finalData['equipmentCode'] = equSelect['code'];
    finalData['equipmentId'] = equSelect['id'];
    finalData['equipmentName'] = equSelect['name'];
    // print('12345${finalData}');
    LoginPrefs.saveUserInfo(jsonEncode(finalData));
    await Request.get("/mes-biz/api/mes/client/user/recordLoginStation",
        params: {
          "orgId": positionSelect['id'],
        });
    await Request.post("/mes-biz/api/operationLog/save", data: {
      "description": '用户:${finalData['employeeName']}切换工序岗位设备',
      "lineId": resData['id'],
      "lineName": resData['name'],
      "stationId": positionSelect['id'],
      "stationName": positionSelect['name'],
      "title": '切换工序岗位设备',
    });
    boolApi = false;
  }

  Future<void> changeProcess() async {
    // await getPositionList();
    await getEquipmentList();
    await queryLineByStation();
  }

  Future<void> changeText() async {
    var barcodeInfo = await getDetails();

    _userModel.setBarcodeinfo(barcodeInfo ?? {});
    setState(() {});

    print('当前生产剑豪数据:${barcodeInfo}');
    if (barcodeInfo != null && barcodeInfo['opMode'] == 4) {
      _userModel.setActiveIndex(1);
      print('#####自动执行开始作业');
      _userModel.autoBegin();
      _userModel.refreshfocus();
      // _userModel.refreshWeight();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _userModel = Provider.of<UserModel>(context, listen: false);
    super.initState();
    var userInfoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // var autoInfoData = jsonDecode(LoginPrefs.getAutoUserInfo() ?? '');
    // var autoInfoData = LoginPrefs.getAutoUserInfo() ?? '';
    usernamefocusNode.requestFocus();
    startTimer();
    // if (autoInfoData != '') {
    //   print('当前自动岗用户信息：${autoInfoData}');
    // print('链接mq！！！！！');
    // initmq();
    // }
    positionSelect['id'] = userInfoData['stationId'];
    positionSelect['name'] = userInfoData['stationName'];
    positionSelect['code'] = userInfoData['stationCode'];

    getPeocessList();
    _userModel.savefocusFn(() => {usernamefocusNode.requestFocus()});

    // Exchange exchange = await channel.exchange("logs", ExchangeType.FANOUT);
  }

  @override
  void deactivate() {
    // TODO: implement dispose
    // client.close();
    stopTimer();
    super.deactivate();
  }

  var boolApi = false;
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    var userInfo = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    return Container(
      width: 500,
      height: 844,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/submit-card-bgc.png'),
              fit: BoxFit.fill)),
      margin: const EdgeInsets.only(left: 30, top: 180),
      child: Column(children: [
        Container(
          width: 500,
          height: 64,
          padding: const EdgeInsets.only(left: 56, top: 8),
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/submit-card-title.png'),
                  fit: BoxFit.fill)),
          child: const Text(
            '生产报工',
            style: TextStyle(
                fontSize: 32,
                color: Color(0xffffffff),
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                Expanded(
                  child: Scrollbar(
                    // showTrackOnHover: true,

                    /// 滚动条的宽度
                    thickness: 12,

                    /// 滚动条两端的圆角半径
                    radius: const Radius.circular(11),

                    /// 是否显示滚动条滑块
                    thumbVisibility: true,

                    /// 是否显示滚动条轨道
                    trackVisibility: true,

                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 20),
                      primary: true,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: processList
                            .map((rowdata) => InkWell(
                                  onTap: () async {
                                    print('rowdata${rowdata}');

                                    if (rowdata['processid'] !=
                                            userInfo['processId'] &&
                                        !boolApi) {
                                      setState(() {
                                        positionSelect['id'] = rowdata['id'];
                                        positionSelect['name'] =
                                            rowdata['name'];
                                        positionSelect['code'] =
                                            rowdata['code'];
                                        processSelect['id'] =
                                            rowdata['processid']!;
                                        processSelect['name'] =
                                            rowdata['processname']!;
                                        processSelect['code'] =
                                            rowdata['processcode']!;
                                      });
                                      print('userInfoData');
                                      boolApi = true;

                                      await changeProcess();

                                      userModel.setInfo({
                                        'processId': processSelect,
                                        'positionId': positionSelect,
                                      });
                                      // if (rowdata['opMode'] == 4) {
                                      //   userModel.setActiveIndex(1);
                                      // } else {
                                      //   userModel.setActiveIndex(0);
                                      // }
                                      userModel.refreshWeight();
                                      usernamefocusNode.requestFocus();

                                      print(processSelect);
                                    }
                                  },
                                  highlightColor: Colors.transparent, // 透明色
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    height: 60,
                                    width: 150,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                    ),
                                    // padding: EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 12),
                                    decoration: BoxDecoration(
                                        color: positionSelect['id'] ==
                                                rowdata['id']
                                            ? Color(0xff004dc5)
                                            : Color.fromARGB(23, 31, 94, 255),
                                        border: Border.all(
                                            color: Color(0xff0057d9),
                                            width: 1)),
                                    child: (Text(rowdata['name'].toString(),
                                        // overflow: TextOverflow.ellipsis,
                                        // maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ))),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 20, left: 8),
                  child: IconButton(
                      color: Colors.white,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent, // 透明色
                      splashColor: Colors.transparent,
                      onPressed: () {
                        userModel.setBarcodeinfo({});
                        userModel.setInfo({'processId': '', 'positionId': ''});
                        userModel.setActiveIndex(0);
                      },
                      icon: Icon(Icons.more_horiz)),
                )
              ],
            )),
        // SizedBox(
        //   height: 10,
        // ),
        Container(
          width: 460,
          height: 80,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/submit-card-input.png'))),
          child: Row(children: [
            Container(
              // width: 338,
              width: 450,
              height: 60,
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: usernameInput(username, changeText, usernamefocusNode),
            ),
            // OutlinedButton(
            //     onPressed: () async {
            //       if (username.text.isEmpty) {
            //         EasyLoading.showError('请扫描条码');
            //       } else {
            //         var barcodeInfo = await getDetails();
            //         userModel.setBarcodeinfo(barcodeInfo ?? {});
            //         setState(() {});
            //       }
            //     },
            //     style: OutlinedButton.styleFrom(
            //         minimumSize: const Size(100, 54),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(3),
            //         ),
            //         side: const BorderSide(
            //             width: 1, color: Color.fromARGB(135, 0, 148, 255)),
            //         backgroundColor: const Color.fromARGB(112, 0, 94, 236)),
            //     child: const Text(
            //       '确认',
            //       style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 26,
            //           fontWeight: FontWeight.w700),
            //     ))
          ]),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: 460,
          height: 51,
          color: const Color(0xff062969),
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '产品件号',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                barCode.isNotEmpty ? barCode : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        Container(
          width: 460,
          height: 51,
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '状态编码',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                detailData['materialCode'] != null
                    ? detailData['materialCode']
                    : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        Container(
          width: 460,
          height: 51,
          color: const Color(0xff062969),
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '产品名称',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                detailData['materialName'] != null
                    ? detailData['materialName']
                    : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        Container(
          width: 460,
          height: 51,
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '生产订单号',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                detailData['produceOrderNo'] != null
                    ? detailData['produceOrderNo']
                    : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        Container(
          width: 460,
          height: 51,
          color: const Color(0xff062969),
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '产线',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                detailData['lineName'] != null ? detailData['lineName'] : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        Container(
          width: 460,
          height: 51,
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '计划生产数量',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                detailData['planProduceNum'] != null
                    ? detailData['planProduceNum'].toString()
                    : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        Container(
          width: 460,
          height: 51,
          color: const Color(0xff062969),
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '上线数量',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                detailData['onlineNum'] != null
                    ? detailData['onlineNum'].toString()
                    : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        Container(
          width: 460,
          height: 51,
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '下线数量',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                detailData['offlineNum'] != null
                    ? detailData['offlineNum'].toString()
                    : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        Container(
          width: 460,
          height: 51,
          color: const Color(0xff062969),
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: [
            SizedBox(
              width: 145,
              child: Text(
                '预计结束时间',
                style: _labelTextStyle,
              ),
            ),
            Flexible(
              child: Text(
                detailData['planEndTime'] != null
                    ? detailData['planEndTime'].toString()
                    : '-',
                overflow: TextOverflow.ellipsis,
                style: _labelTextStyle,
              ),
            )
          ]),
        ),
        const SizedBox(
          height: 60,
          width: 460,
          child: Divider(
            color: Color.fromARGB(255, 0, 59, 148),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(),
              child: OutlinedButton(
                  onPressed: () {
                    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
                    // if (detailData['opMode'] == 3 &&
                    //     detailData['opMode'] == 4) {
                    //   EasyLoading.showError('当前工序不支持手动报工');
                    // } else {
                    print('${username.text}评审');
                    if (detailData['materialCode'] != null) {
                      if (detailData['opMode'] != 1) {
                        EasyLoading.showError('当前工序不支持手动报工');
                      } else {
                        showDialogFunction(context, {
                          'width': 500.0,
                          'height': 150.0,
                          'title': '确认提示',
                          'onSubmit': () {
                            return submitDetail(3);
                          },
                          'content': Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '是否确定要评审当前产品件号${barCode}？',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                ),
                                Text(
                                  '确认后将移交评审',
                                  style: TextStyle(
                                      color: Color.fromARGB(90, 255, 255, 255),
                                      fontSize: 24),
                                ),
                              ])
                        });
                      }
                    } else {
                      EasyLoading.showError('请先扫件！');
                      usernamefocusNode.requestFocus();
                    }
                    // }
                  },
                  style: OutlinedButton.styleFrom(
                      fixedSize: const Size(145, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      side:
                          const BorderSide(width: 1, color: Color(0xff0085ff)),
                      backgroundColor: const Color.fromARGB(23, 0, 133, 255)),
                  child: const Text(
                    '评审',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700),
                  )),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(radius: 2, colors: [
                  Color.fromARGB(0, 153, 0, 0),
                  Color.fromARGB(64, 255, 0, 0)
                ]),
                //背景渐变
              ),
              child: OutlinedButton(
                  onPressed: () async {
                    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');

                    print('${detailData}确认');
                    //调取不合格列表
                    if (detailData['materialCode'] != null) {
                      if (detailData['opMode'] != 1) {
                        EasyLoading.showError('当前工序不支持手动报工');
                      } else {
                        selectDefect = {};
                        // await getqueryDefect();
                        showDialogFunction(context, {
                          'title': '不合格上报',
                          'width': 1050.0,
                          'content': ModalSelect(),
                          'onSubmit': () {
                            // return submitDetail(2);
                            if (selectDefect['id'] != null) {
                              Navigator.of(context).pop();
                              showDialogFunction(context, {
                                'title': '缺陷标记',
                                'width': 1050.0,
                                'content': ModalPicture(),
                                'onSubmit': () {
                                  return submitDetail(2);
                                }
                              });
                              return false;
                            } else {
                              EasyLoading.showError('缺陷不能为空');
                              return false;
                            }
                          },
                          'onCancel': () {
                            selectDefect = {};
                          },
                        });
                      }
                    } else {
                      EasyLoading.showError('请先扫件！');
                      usernamefocusNode.requestFocus();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                      fixedSize: const Size(145, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      side:
                          const BorderSide(width: 1, color: Color(0xffb52929)),
                      // shadowColor: Color.fromARGB(135, 0, 133, 255),
                      // elevation: 5.0,
                      backgroundColor: const Color.fromARGB(40, 245, 46, 46)),
                  child: const Text(
                    '不合格',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700),
                  )),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(radius: 2, colors: [
                  Color.fromARGB(0, 0, 255, 255),
                  Color.fromARGB(186, 0, 208, 236)
                ]),
                //背景渐变
              ),
              child: OutlinedButton(
                  onPressed: () {
                    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
                    // if (detailData['opMode'] == 3 &&
                    //     detailData['opMode'] == 4) {
                    //   EasyLoading.showError('当前工序不支持手动报工');
                    // } else {
                    print('${username.text}确认');
                    if (detailData['materialCode'] != null) {
                      if (detailData['opMode'] != 1) {
                        EasyLoading.showError('当前工序不支持手动报工');
                      } else {
                        if (!boolApi) {
                          submitDetail(1);
                        }
                      }
                    } else {
                      EasyLoading.showError('请先扫件！');
                      usernamefocusNode.requestFocus();
                    }
                    // }
                  },
                  style: OutlinedButton.styleFrom(
                      fixedSize: const Size(145, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      side:
                          const BorderSide(width: 1, color: Color(0xff52fefe)),
                      backgroundColor: const Color.fromARGB(20, 0, 222, 236)),
                  child: const Text(
                    '合格',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700),
                  )),
            ),
          ],
        )
      ]),
    );
  }
}

//弹窗
/// showDialog
showDialogFunction(context, config) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          backgroundColor: Color.fromARGB(204, 0, 44, 109),
          titlePadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            // 边框形状
            borderRadius: BorderRadius.circular(0),
          ),
          title: Container(
              width: config['width'] ?? 1000,
              height: 72,
              padding:
                  EdgeInsets.only(left: 32, top: 20, bottom: 20, right: 10),
              color: Color.fromARGB(255, 38, 103, 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    config['title'] ?? '提示',
                    style: TextStyle(color: Colors.white),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
              )),
          content: Container(
            width: config['width'] ?? 1000,
            height: config['height'] ?? 500,
            child: config['content'],
          ),
          actions: [
            OutlinedButton(
                onPressed: () {
                  if (config['onCancel'] != null) {
                    config['onCancel']();
                  }
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                    fixedSize: const Size(100, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    side: const BorderSide(width: 1, color: Color(0xff0085ff)),
                    backgroundColor: const Color.fromARGB(23, 0, 133, 255)),
                child: const Text(
                  '取消',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                )),
            config['expentBtn'] ?? SizedBox(),
            OutlinedButton(
                onPressed: () async {
                  print(config['onSubmit']);
                  if (config['onSubmit'] != null) {
                    final asyncOperationResult = await config['onSubmit']();
                    print('弹窗内部：${asyncOperationResult}');
                    if (asyncOperationResult) {
                      if (config['onCancel'] != null) {
                        config['onCancel']();
                      }
                      print('开关：${config['disableClose'] == true}');
                      if (config['disableClose'] != true) {
                        Navigator.of(context).pop();
                      }
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                    fixedSize: Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    side: const BorderSide(width: 1, color: Color(0xff0085ff)),
                    backgroundColor: const Color.fromARGB(23, 0, 133, 255)),
                child: Text(
                  config['okText'] ?? '提交',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                )),
          ]);
    },
  );
}

//输入框确认按钮
OutlineInputBorder _outlineInputBorder = const OutlineInputBorder(
  gapPadding: 0,
  borderSide: BorderSide(
    color: Color(0xff4b74dc),
  ),
);

Widget usernameInput(TextEditingController username, changeText, focusNode) {
  var changeTextBool = false;
  final changeTextDebouncer = Debouncer(Duration(milliseconds: 300), () async {
    await changeText();
    changeTextBool = false;
  });
  return TextFormField(
    controller: username,
    cursorColor: Colors.white,
    style: const TextStyle(
      color: Colors.white,
    ),
    onChanged: (value) async {
      // print(value);
      if (value.length >= 25) {
        if (!changeTextBool) {
          changeTextDebouncer();
        } else {
          print('请求太频繁啦！！！');
        }
      }
      // var barcodeInfo = await getDetails();

      //                   userModel.setBarcodeinfo(barcodeInfo ?? {});
      //                   setState(() {});
    },
    decoration: InputDecoration(
      filled: true,
      fillColor: Color.fromARGB(255, 0, 27, 68),
      hintText: '请扫描或输入',
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
    onSaved: (v) => username.text = v!,
  );
}

Map selectDefect = {};
List defectList = [];
List pictureList = [];
List<Widget> defectCodeListToWidgets(
    List<dynamic> defectCodeList, context, updateUi) {
  return defectCodeList.map((subitem) {
    return InkWell(
      onTap: () {
        updateUi();
        print(subitem);
        selectDefect['id'] = subitem['id'];
        selectDefect['code'] = subitem['code'];
        selectDefect['name'] = subitem['name'];
      },
      highlightColor: Colors.transparent, // 透明色
      splashColor: Colors.transparent,
      child: Container(
        height: 64,
        width: 250,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 12),
        decoration: BoxDecoration(
            color: selectDefect['id'] == subitem['id']
                ? Color(0xff004dc5)
                : Color.fromARGB(23, 31, 94, 255),
            border: Border.all(color: Color(0xff0057d9), width: 1)),
        child: (Text(subitem['name'].toString(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ))),
      ),
    );
  }).toList();
}

class ModalSelect extends StatefulWidget {
  const ModalSelect({super.key});

  @override
  State<ModalSelect> createState() => _ModalSelectState();
}

class _ModalSelectState extends State<ModalSelect> {
  //不合格-获取所有分类缺陷
  Future<void> getqueryDefect() async {
    var response = await Request.get("/mes-biz/api/mes/client/task/queryDefect",
        params: {'enableUse': 1});
    if (response["success"]) {
      var resData = response["data"] ?? {};
      defectList = resData;
      print(resData);
    } else {
      EasyLoading.showError(response["message"]);
    }
    setState(() {});
  }

  void updateUi() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getqueryDefect();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: defectList
              .map((item) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 18,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xff0057d9), width: 1)),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              item['name'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        Wrap(
                            spacing: 10.0, // 主轴(水平)方向间距
                            runSpacing: 24.0, // 纵轴（垂直）方向间距
                            alignment: WrapAlignment.start, //沿主轴方向居中
                            children: defectCodeListToWidgets(
                                item['defectCodeList'], context, updateUi)),
                        SizedBox(
                          height: 52,
                        ),
                      ]))
              .toList()),
    );
  }
}

//弹窗内图片列表组件
class ModalPicture extends StatefulWidget {
  const ModalPicture({super.key});

  @override
  State<ModalPicture> createState() => _ModalPictureState();
}

class _ModalPictureState extends State<ModalPicture> {
  //不合格-获取缺陷标记图片列表
  Future<void> getMaterialAttachment() async {
    var materialInfo = jsonDecode(LoginPrefs.getMaterialInfo() ?? '');
    print(materialInfo['materialId']);
    var response = await Request.get(
        "/mes-biz/api/mes/materialattachment/attachments/${materialInfo['materialId']}/1/100",
        params: {'purpose': 2});
    if (response["success"]) {
      var resData = response["data"]['records'] ?? {};

      print(resData);
      pictureList = resData;
    } else {
      EasyLoading.showError(response["message"]);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getMaterialAttachment();
    print("缺陷标记图片列表");
    print(LoginPrefs.getMaterialInfo());
  }

  @override
  void dispose() {
    pictureList = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return SingleChildScrollView(
        child: Wrap(
      spacing: 10.0, // 主轴(水平)方向间距
      runSpacing: 24.0, // 纵轴（垂直）方向间距
      alignment: WrapAlignment.start, //沿主轴方向居中
      children: pictureList
          .map((item) => InkWell(
                onTap: () {
                  // updateUi();

                  setState(() {});
                  showDialogFunction(context, {
                    'title': '图片标记',
                    'width': 1050.0,
                    'content': PictureDetail(
                        imgurl: item['url'], imgname: item['attachmentName']),
                    'onSubmit': () async {
                      var result = await userModel.getExportImageFn();
                      if (result != null) {
                        item['url'] = result;
                        item['select'] = true;
                        setState(() {});

                        return true;
                      } else {
                        return false;
                      }
                    },
                    'okText': '完成',
                  });
                  print(item);
                },
                highlightColor: Colors.transparent, // 透明色
                splashColor: Colors.transparent,
                child: Container(
                  height: 64,
                  width: 500,
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                      color: item['select'] ?? false
                          ? Color(0xff004dc5)
                          : Color.fromARGB(23, 31, 94, 255),
                      border: Border.all(color: Color(0xff0057d9), width: 1)),
                  child: (Text(item['attachmentName'].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ))),
                ),
              ))
          .toList(),
    ));
  }
}

//编辑图片组件
class PictureDetail extends StatefulWidget {
  const PictureDetail({super.key, required this.imgurl, required this.imgname});
  final String imgurl;
  final String imgname;

  @override
  State<PictureDetail> createState() => _PictureDetailState();
}

class _PictureDetailState extends State<PictureDetail> {
  var address;
  late final UserModel _userModel;
  final imagePainterController = ImagePainterController(color: Colors.red);

  //登录鉴权
  Future zdLogin() async {
    var password = await encodeString('abc123ABC*');
    print('用户信息：${password}');
    var params = {
      // 'barCode': username.text,
      // "userName": "10003",//prod
      "userName": "humi001", //test
      'password': password,
    };
    print('接口提交信息${params}');

    var response = await Request.post(
      "/rest/core/auth/login",
      data: params,
      baseUrl: Constant.zdUrl,
    );
    if (response["state"]) {
      print('接口返回数据：${response["identitytoken"]}');
      LoginPrefs.saveIdentitytoken(response["identitytoken"]);
      return response["identitytoken"];
    } else {
      EasyLoading.showError(response["message"]);
      return '';
    }
  }

  Future getUrl(fileName) async {
    print("fileName:$fileName");
    Map<String, dynamic> jsonMap = jsonDecode(fileName);
    var _fileName = jsonMap.keys.first;

    print("_fileName:$_fileName");
    // var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // String clientToken = await zdLogin();
    // print('clientId：${clientToken}');
    // print(infoData);
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

    print("${response['data']}");
    setState(() {
      address = "${response['data']}";
    });

    return "https://${response['data']}";
  }

  Future uploadPic(file) async {
    // var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // String clientToken = await zdLogin();
    // print('clientId：${clientToken}');
    // print(infoData);
    // var params = {
    //   'fileName': file,
    //   "bucket": 'zd-ipass-test',
    //   "accessKey": 'bCQDlLS-d_oedUil78rnlRDJxXFQaq45ucY3P5Bx',
    //   "secretKey": 'fQ0qxCo8Bn0nel0R7jywaY9wR4Vb9hPPpz6jsIZF',
    //   // "identitytoken": clientToken
    // };
    // print('接口提交信息${params}');

    var response = await Request.post(
      "/mes-admin/file/upload",
      data: file,
    );
    print('接口返回数据：${response}');
    if (response['data'] != null) {
      return response['data'];
    }
  }

  Future savePicture() async {
    Uint8List? byteArray = await imagePainterController.exportImage();
    // 创建MultipartFile从Uint8List
    MultipartFile multipartFile = MultipartFile.fromBytes(
      byteArray as List<int>, // Uint8List数据
      filename: widget.imgname, // 文件名
      contentType: MediaType.parse('image/png'), // 根据实际情况设置MIME类型，这里是图片作为示例
    );
    // 创建FormData并添加MultipartFile
    FormData formData = FormData.fromMap({
      'file': multipartFile,

      // "bucketName": 'zd-ipass-test',
      // "accessKey": 'bCQDlLS-d_oedUil78rnlRDJxXFQaq45ucY3P5Bx',
      // "secretKey": 'fQ0qxCo8Bn0nel0R7jywaY9wR4Vb9hPPpz6jsIZF',
      // "bucketName": 'hc-mes',
      // "accessKey": 'zBj4f0g70p8cNO0Q6dP-Ul3l7fKhj7_sayruZC8I',
      // "secretKey": 'jlmMVSxZbDtOhllWfOR0z4zrx6YYNZW69Dx9Fp_X',

      // 可以在这里添加其他字段，例如：'description': 'This is a test file'
    });
    var uploadresult = await uploadPic(formData);
    print(uploadresult);
    return uploadresult;

    // final directory = Directory('lib/utils');
    // if (!directory.existsSync()) {
    //   // 如果目录不存在，则创建它
    //   directory.createSync(recursive: true);
    // }
    // final filePath = directory.path + '/mypicture.png';
    // File imgFile = File(filePath);
    // imgFile.writeAsBytesSync(byteArray as List<int>);
    // print(imgFile);
  }

  @override
  void initState() {
    _userModel = Provider.of<UserModel>(context, listen: false);
    _userModel.saveExportImageFn(() async {
      return await savePicture();
      // print('保存函数：${await savePicture()}');
    });
    super.initState();
    print(widget.imgurl);
    getUrl(widget.imgurl);
    // loadAsset("images/cad-test.jpg");
    print('地址：${address}');
  }

  @override
  void dispose() {
    // 移除监听器
    address = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialize `ImagePainterController`.
    return address != null
        ? ImagePainter.network(address,
            controller: imagePainterController, scalable: true)
        : Container();
  }
}
