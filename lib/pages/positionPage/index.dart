import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hc_mes_app/common/login_prefs.dart';
import 'package:hc_mes_app/main.dart';
import 'package:hc_mes_app/pages/call/index.dart';
import 'package:hc_mes_app/pages/home/home.dart';
import '../../common//dio_request.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  late final UserModel _userModel;
  var processSelect = {}; // 目标列表项的索引
  var positionSelect = {}; // 目标列表项的索引
  var equSelect = {}; // 目标列表项的索引
  int activeIndex = 0;
  List processList = [];
  List positionList = [];
  List equList = [];

  @override
  void initState() {
    _userModel = Provider.of<UserModel>(context, listen: false);
    super.initState();
    // 初始化数据
    initPage();
  }

  Future<void> initPage() async {
    // await getPeocessList();
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    if (finalData['lineId'] == null) {
      //登录傻瓜式自动选择逻辑实现
      await getPeocessList();
      // if (processList.length > 0) {
      //   processSelect['id'] = processList[0]['id'];
      //   processSelect['name'] = processList[0]['name'];
      //   processSelect['code'] = processList[0]['code'];
      // await getPositionList();
      if (positionList.length > 0) {
        positionSelect['id'] = positionList[0]['id'];
        positionSelect['name'] = positionList[0]['name'];
        positionSelect['code'] = positionList[0]['code'];
        positionSelect['processid'] = positionList[0]['processid'];
        positionSelect['processname'] = positionList[0]['processname'];
        positionSelect['processcode'] = positionList[0]['processcode'];
        await getEquipmentList();
        if (equList.length > 0) {
          equSelect['id'] = equList[0]['id'];
          equSelect['name'] = equList[0]['name'];
          equSelect['code'] = equList[0]['code'];
        }
      }
      // }
    } else {
      //切换岗位傻瓜式自动选择逻辑实现
      await getPeocessList();
      // if (processList.length > 0) {
      //   processSelect['id'] = finalData['processId'];
      //   processSelect['name'] = finalData['processName'];
      //   processSelect['code'] = finalData['processCode'];
      //   await getPositionList();
      if (positionList.length > 0) {
        positionSelect['id'] = finalData['stationId'];
        positionSelect['name'] = finalData['stationName'];
        positionSelect['code'] = finalData['stationCode'];
        positionSelect['processid'] = finalData['processId'];
        positionSelect['processname'] = finalData['processName'];
        positionSelect['processcode'] = finalData['processCode'];
        await getEquipmentList();
        if (equList.length > 0) {
          equSelect['id'] = finalData['equipmentId'];
          equSelect['name'] = finalData['equipmentName'];
          equSelect['code'] = finalData['equipmentCode'];
        }
      }
      // }
    }
  }

  Future<void> getPeocessList() async {
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    var macinfo = List.from(Set.from(getLocalMacAddress()['mac']));
    print('mac:${finalData['mac']}');
    if (finalData['mac'] == null) {
      for (var i = 0; i < macinfo.length; i++) {
        print(macinfo[i]);
        print(i);
        var processResponse = await Request.get(
            // "/mes-biz/api/mes/client/user/queryProcessByLine",
            // params: {'orgId': finalData['orgId']}
            "/mes-biz/api/mes/client/user/queryStationByMac",
            params: {'mac': macinfo[i]});
        print('processResponse${processResponse}');
        // var response = await Request.get(
        //   "/mes-biz/api/mes/client/user/queryProcessByUser",
        // );
        if (processResponse["success"]) {
          List resData = processResponse["data"] ?? [];
          finalData['mac'] = macinfo[i];
          finalData['hasReview'] = resData
              .map((item) => item['stationName'])
              .toList()
              .any((element) => element.contains('全检'));
          print('权限判断：${finalData['hasReview']}');
          LoginPrefs.saveUserInfo(jsonEncode(finalData));
          print('查看接口数据1111 ${resData}');
          // if (resData.length > 0) {
          //   // var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
          //   finalData['employeeId'] = resData[0]['empId'];
          //   LoginPrefs.saveUserInfo(jsonEncode(finalData));
          // }
          // processList = resData
          //     .map((e) => ({
          //           'id': e['processCellId'],
          //           'name': e['processCellName'],
          //           'code': e['processCellCode'],
          //         }))
          //     .toList();
          positionList = resData
              .map((e) => ({
                    'id': e['stationId'],
                    'name': e['stationName'],
                    'code': e['stationCode'],
                    'processid': e['processCellId'],
                    'processname': e['processCellName'],
                    'processcode': e['processCellCode'],
                  }))
              .toList();

          //获取自动打码工序信息
//       var autoProcess = resData.firstWhere(
//         (item) => item['opMode'] == 3,
//         orElse: () => null,
//       );
//       print('自动打码工序信息${autoProcess}');
//       if (autoProcess != null) {
//         //岗位
//         var autoPositionRes = await Request.get(
//             "/mes-biz/api/mes/client/user/queryStationByProcess",
//             params: {
//               "processId": autoProcess['processCellId'],
//             });

//         var autoPosition = autoPositionRes["data"][0];

//         //设备
//         var autoEquipmentRes = await Request.post("/mes-eam/equipment/page",
//             data: {
//               "size": 500,
//               'current': 1,
//               'positionId': autoPosition['id']
//             });

//         var autoEquipment = autoEquipmentRes["data"]['records'][0];

// //存储自动打码信息
//         var autoInfo = {
//           'processId': autoProcess['processCellId'],
//           'processCode': autoProcess['processCellCode'],
//           'processName': autoProcess['processCellName'],
//           'stationId': autoPosition['id'],
//           'stationCode': autoPosition['code'],
//           'stationName': autoPosition['name'],
//           'equipmentId': autoEquipment['id'],
//           'equipmentCode': autoEquipment['code'],
//           'equipmentName': autoEquipment['name'],
//         };
//         print('自动打码工序信息${autoInfo}');
//         LoginPrefs.saveAutoUserInfo(jsonEncode(autoInfo));
//       }
          setState(() {});
          return;
        } else {
          // _userModel.setToken('');
          EasyLoading.showError('${processResponse['message']}');
        }

        if (i == macinfo.length - 1) {
          // print('弹出');
          _userModel.setToken('');
        }
      }
    } else {
      var processResponse = await Request.get(
          // "/mes-biz/api/mes/client/user/queryProcessByLine",
          // params: {'orgId': finalData['orgId']}
          "/mes-biz/api/mes/client/user/queryStationByMac",
          params: {'mac': finalData['mac']});
      print('processResponse${processResponse}');
      // var response = await Request.get(
      //   "/mes-biz/api/mes/client/user/queryProcessByUser",
      // );
      if (processResponse["success"]) {
        List resData = processResponse["data"] ?? [];
        print('查看接口数据1111 ${resData}');

        positionList = resData
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
        _userModel.setToken('');
        EasyLoading.showError('${processResponse['message']}');
      }
    }
  }

  Future<void> getPositionList() async {
    var response = await Request.get(
        "/mes-biz/api/mes/client/user/queryStationByProcess",
        params: {
          "processId": processSelect['id'],
        });
    var resData = response["data"] ?? {};
    print('12345${response}');
    positionList = resData
        .map((e) => ({'id': e['id'], 'name': e['name'], 'code': e['code']}))
        .toList();
    print(positionList);
    setState(() {});
  }

  Future<void> getEquipmentList() async {
    var response = await Request.post("/mes-eam/equipment/page",
        data: {"size": 500, 'current': 1, 'positionId': positionSelect['id']});

    if (response["success"]) {
      var resData = response["data"]['records'] ?? [];
      print('12345${response}');
      equList = resData
          .map((e) => ({'id': e['id'], 'name': e['name'], 'code': e['code']}))
          .toList();
      print(positionList);
      setState(() {});
    } else {
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
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('||||||||||||||||||${finalData}');
    if (finalData['stationId'] == null) {
      await Request.post("/mes-biz/api/operationLog/save", data: {
        "description": '用户:${finalData['employeeName']}登录成功',
        "lineId": resData['id'],
        "lineName": resData['name'],
        "stationId": positionSelect['id'],
        "stationName": positionSelect['name'],
        "title": '登录成功',
      });
    } else {
      await Request.post("/mes-biz/api/operationLog/save", data: {
        "description": '用户:${finalData['employeeName']}切换工序岗位设备',
        "lineId": resData['id'],
        "lineName": resData['name'],
        "stationId": positionSelect['id'],
        "stationName": positionSelect['name'],
        "title": '切换工序岗位设备',
      });
    }
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
    print('12345${finalData}');
    LoginPrefs.saveUserInfo(jsonEncode(finalData));
    await Request.get("/mes-biz/api/mes/client/user/recordLoginStation",
        params: {
          "orgId": positionSelect['id'],
        });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Container(
      width: 1920,
      height: 1080,
      padding: const EdgeInsets.only(left: 57, right: 57),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/login-bg.png'), fit: BoxFit.cover)),
      // color: Colors.blue,
      child: Center(
        child: Container(
          height: 800,
          width: 500,
          // color: Colors.blue,
          // padding: EdgeInsets.only(left: 40),
          child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   alignment: Alignment.topLeft,
                //   // padding: EdgeInsets.only(left: 40),
                //   child: Text(
                //     '工序选择',
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 22,
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 20,
                // ),
                // Expanded(
                //     flex: 1,
                //     child: SingleChildScrollView(
                //       child: Wrap(
                //         spacing: 8.0, // 主轴(水平)方向间距
                //         runSpacing: 20.0, // 纵轴（垂直）方向间距
                //         alignment: WrapAlignment.start, //沿主轴方向居中
                //         children: processList
                //             .map((rowdata) => InkWell(
                //                   onTap: () {
                //                     setState(() {
                //                       processSelect['id'] = rowdata['id'];
                //                       processSelect['name'] = rowdata['name'];
                //                       processSelect['code'] = rowdata['code'];
                //                       processSelect['opMode'] =
                //                           rowdata['opMode'];
                //                       positionSelect = {};
                //                       equSelect = {};
                //                       equList = [];
                //                     });
                //                     // getPositionList();
                //                     print(processList);
                //                     print(processSelect);
                //                   },
                //                   highlightColor: Colors.transparent, // 透明色
                //                   splashColor: Colors.transparent,
                //                   child: Container(
                //                     height: 60,
                //                     width: 150,
                //                     alignment: Alignment.center,
                //                     padding: EdgeInsets.only(
                //                       left: 12,
                //                       right: 12,
                //                     ),
                //                     // padding: EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 12),
                //                     decoration: BoxDecoration(
                //                         color: processSelect['id'] ==
                //                                 rowdata['id']
                //                             ? Color(0xff004dc5)
                //                             : Color.fromARGB(23, 31, 94, 255),
                //                         border: Border.all(
                //                             color: Color(0xff0057d9),
                //                             width: 1)),
                //                     child: (Text(rowdata['name'].toString(),
                //                         // overflow: TextOverflow.ellipsis,
                //                         // maxLines: 1,
                //                         style: TextStyle(
                //                           fontSize: 16,
                //                           color: Colors.white,
                //                         ))),
                //                   ),
                //                 ))
                //             .toList(),
                //       ),
                //     )),
                // SizedBox(
                //   height: 20,
                // ),
                Container(
                  alignment: Alignment.topLeft,
                  // padding: EdgeInsets.only(left: 40),
                  child: Text(
                    '岗位选择',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0, // 主轴(水平)方向间距
                        runSpacing: 20.0, // 纵轴（垂直）方向间距
                        alignment: WrapAlignment.start, //沿主轴方向居中
                        children: positionList
                            .map((rowdata) => InkWell(
                                  onTap: () {
                                    print('岗位code：${rowdata['code']}');

                                    setState(() {
                                      positionSelect['id'] = rowdata['id']!;
                                      positionSelect['name'] = rowdata['name']!;
                                      positionSelect['code'] = rowdata['code']!;
                                      positionSelect['processid'] =
                                          rowdata['processid']!;
                                      positionSelect['processname'] =
                                          rowdata['processname']!;
                                      positionSelect['processcode'] =
                                          rowdata['processcode']!;

                                      equSelect = {};
                                    });
                                    getEquipmentList();
                                    print(positionSelect);
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
                    )),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  // padding: EdgeInsets.only(left: 40),
                  child: Text(
                    '设备选择',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0, // 主轴(水平)方向间距
                        runSpacing: 20.0, // 纵轴（垂直）方向间距
                        alignment: WrapAlignment.start, //沿主轴方向居中
                        children: equList
                            .map((rowdata) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      equSelect['id'] = rowdata['id']!;
                                      equSelect['name'] = rowdata['name']!;
                                      equSelect['code'] = rowdata['code']!;
                                    });
                                    print(positionSelect);
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
                                    decoration: BoxDecoration(
                                        color: equSelect['id'] == rowdata['id']
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
                    )),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // OutlinedButton(
                    //     onPressed: () {
                    //       print('返回');
                    //       userModel.setToken('');
                    //     },
                    //     style: OutlinedButton.styleFrom(
                    //         fixedSize: const Size(145, 54),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(3),
                    //         ),
                    //         side: const BorderSide(
                    //             width: 1, color: Color(0xff0085ff)),
                    //         backgroundColor:
                    //             const Color.fromARGB(23, 0, 133, 255)),
                    //     child: const Text(
                    //       '返回',
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 26,
                    //           fontWeight: FontWeight.w700),
                    //     )),
                    OutlinedButton(
                        onPressed: () async {
                          print('确认${processSelect} ${positionSelect}');

                          if (
                              // processSelect['id'] != null &&
                              positionSelect['id'] != null &&
                                  equSelect['id'] != null) {
                            processSelect['id'] = positionSelect['processid'];
                            processSelect['name'] =
                                positionSelect['processname'];
                            processSelect['code'] =
                                positionSelect['processcode'];
                            print('processSelect$processSelect');
                            await queryLineByStation();
                            userModel.setInfo({
                              'processId': processSelect,
                              'positionId': positionSelect,
                              'equipmentId': equSelect,
                            });
                          } else {
                            EasyLoading.showError("请完成工序，岗位，设备的选择");
                          }
                        },
                        style: OutlinedButton.styleFrom(
                            fixedSize: const Size(145, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            side: const BorderSide(
                                width: 1, color: Color(0xff52fefe)),
                            backgroundColor:
                                const Color.fromARGB(20, 0, 222, 236)),
                        child: const Text(
                          '确认',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700),
                        ))
                  ],
                )
              ]),
        ),
      ),
    );
  }
}
