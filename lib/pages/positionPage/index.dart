import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_windows_android_app/common/login_prefs.dart';

import 'package:flutter_windows_android_app/pages/home/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './component/selection_widget.dart';
import '../../services/common.dart';

class PositionPage extends StatefulWidget {
  final Function(String)? onConfirm;
  const PositionPage({super.key, this.onConfirm});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  late final UserModel _userModel;
  var lineSelect = {}; // 选中的产线
  var stationSelect = {}; // 选中的岗位
  int activeLineIndex = 0; // 选中的产线索引
  int activeStationIndex = 0; // 选中的岗位索引
  List lineList = []; // 产线列表
  List stationList = []; // 岗位列表
  List subStationList = []; // 子岗位列表
  var subStationSelect = {}; // 选中的子岗位
  bool _showSubStationDialogVisible = false; // 控制子岗位选择弹出框的显示与隐藏

  @override
  void initState() {
    _userModel = Provider.of<UserModel>(context, listen: false);
    super.initState();
    // 初始化数据 - 延迟到构建完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPage();
    });
  }

  Future<void> initPage() async {
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    var orgData = await CommonService.getUserFactoryOrg();

    if (orgData["success"]) {
      lineList = orgData["data"];
      if (lineList.isNotEmpty) {
        // 默认选中第一个产线
        lineSelect = lineList[0];
        activeLineIndex = 0;
        stationList = lineSelect['stationList'] ?? [];

        if (stationList.isNotEmpty) {
          // 默认选中第一个岗位
          stationSelect = stationList[0];
          activeStationIndex = 0;
        }
      }
    }

    // 根据已保存的用户信息进行自动选择
    if (finalData['lineId'] != null && finalData['stationId'] != null) {
      lineSelect = {
        'id': finalData['lineId'],
        'name': finalData['lineName'],
        'code': finalData['lineCode'],
      };
      stationSelect = {
        'id': finalData['stationId'],
        'name': finalData['stationName'],
        'code': finalData['stationCode'],
        'processid': finalData['processId'],
        'processname': finalData['processName'],
        'processcode': finalData['processCode'],
        'children': finalData['stationChildren'] ?? [], // 添加子岗位信息
      };
      // 如果保存的岗位是子岗位，则将其设置为subStationSelect
      if (finalData['isSubStation'] == true) {
        subStationSelect = stationSelect;
        setState(() {
          _showSubStationDialogVisible = true;
        });
        // 找到父岗位
        for (var line in lineList) {
          if (line['id'] == finalData['lineId']) {
            for (var i = 0; i < line['stationList'].length; i++) {
              var station = line['stationList'][i];
              if (station['childStationList'] != null &&
                  station['childStationList'].any(
                    (child) => child['id'] == finalData['stationId'],
                  )) {
                stationSelect = station; // 设置父岗位为当前选择的岗位
                activeStationIndex = i; // 更新activeStationIndex
                break;
              }
            }
            break;
          }
        }
      }
      // 重新加载stationList以确保UI正确显示
      if (lineList.isNotEmpty) {
        for (var i = 0; i < lineList.length; i++) {
          var line = lineList[i];
          if (line['id'] == finalData['lineId']) {
            lineSelect = line;
            activeLineIndex = i;
            stationList = line['stationList'] ?? [];
            for (var j = 0; j < stationList.length; j++) {
              var station = stationList[j];
              if (station['id'] == stationSelect['id']) {
                activeStationIndex = j;
                break;
              }
            }
            break;
          }
        }
      }
    }

    // 在数据更新完成后调用setState
    if (mounted) {
      setState(() {});
    }
  }

  Future updateStation(finalDataString, newStationObj) async {
    var loginInfo = jsonDecode(finalDataString);
    loginInfo['lineId'] = newStationObj['lineId'];
    loginInfo['stationId'] = newStationObj['stationId'];
    LoginPrefs.saveUserInfo(jsonEncode(loginInfo));
    setState(() {});
  }

  Future<String> queryLineByStation() async {
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    finalData['lineName'] = lineSelect['name'];
    finalData['lineCode'] = lineSelect['code'];
    finalData['lineId'] = lineSelect['id'];
    finalData['lineOrgPath'] = lineSelect['orgPath'];
    finalData['processId'] = (subStationSelect['id'] != null
        ? subStationSelect
        : stationSelect)['processid'];
    finalData['processCode'] = (subStationSelect['id'] != null
        ? subStationSelect
        : stationSelect)['processcode'];
    finalData['processName'] = (subStationSelect['id'] != null
        ? subStationSelect
        : stationSelect)['processname'];
    finalData['opMode'] = (subStationSelect['id'] != null
        ? subStationSelect
        : stationSelect)['opMode'];
    finalData['stationId'] = (subStationSelect['id'] != null
        ? subStationSelect
        : stationSelect)['id'];
    finalData['stationCode'] = (subStationSelect['id'] != null
        ? subStationSelect
        : stationSelect)['code'];
    finalData['stationName'] = (subStationSelect['id'] != null
        ? subStationSelect
        : stationSelect)['name'];
    finalData['equipmentCode'] = ''; // 设备选择已移除，此处置空
    finalData['equipmentId'] = ''; // 设备选择已移除，此处置空
    finalData['equipmentName'] = ''; // 设备选择已移除，此处置空
    finalData['isSubStation'] = subStationSelect['id'] != null; // 标记是否为子岗位
    finalData['stationChildren'] =
        stationSelect['children'] ?? []; // 保存子岗位列表，用于自动选择时恢复
    // LoginPrefs.saveUserInfo(jsonEncode(finalData));
    return jsonEncode(finalData);
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    Future<void> handleOk() async {
      if (lineSelect['id'] != null && stationSelect['id'] != null) {
        final finalDataString = await queryLineByStation();
        var newStationObj = {
          'lineId': lineSelect['id'],
          // 有子岗位则选择子岗位，否则选择父岗位
          'stationId': (subStationSelect['id'] != null
              ? subStationSelect
              : stationSelect)['id'],
        };
        userModel.setInfo(newStationObj);
        updateStation(finalDataString, newStationObj);
        if (widget.onConfirm != null) {
          await widget.onConfirm!(finalDataString);
        }
      } else {
        EasyLoading.showError("请完成产线和岗位的选择");
      }
    }

    // 子岗位选择弹出框
    Widget showSubStationDialog(BuildContext context) {
      subStationList = stationSelect['childStationList'] ?? [];
      if (subStationList.isNotEmpty && subStationSelect['id'] == null) {
        setState(() {
          subStationSelect = subStationList[0];
        });
      }
      return Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withAlpha(128),
            barrierSemanticsDismissible: false,
          ),
          AlertDialog(
            backgroundColor: Color.fromRGBO(0, 44, 109, 0.80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
              side: BorderSide(color: Color(0xFF2667FF), width: 1.0),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              height: 64.h,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 102, 255, 0.67),
                    Color.fromRGBO(0, 102, 255, 0.56),
                  ],
                ),
                border: Border.all(width: 2.w, color: Color(0xFF2667FF)),
              ),
              child: Text(
                '选择子岗位',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter dialogSetState) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.w,
                    vertical: 32.h,
                  ),
                  width: 674.w,
                  child: SingleChildScrollView(
                    child: Wrap(
                      key: ValueKey(subStationList.hashCode),
                      spacing: 8.0,
                      runSpacing: 20.0,
                      alignment: WrapAlignment.center,
                      children: subStationList
                          .asMap()
                          .entries
                          .map(
                            (entry) => InkWell(
                              onTap: () {
                                dialogSetState(() {
                                  subStationSelect = Map.from(entry.value);
                                });
                              },
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              child: Container(
                                key: ValueKey(entry.value['id']),
                                height: 64.h,
                                width: 293.w,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                  left: 12.w,
                                  right: 12.w,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      subStationSelect['id'].toString() ==
                                          entry.value['id'].toString()
                                      ? Color(0xff004dc5)
                                      : Color.fromARGB(23, 31, 94, 255),
                                  border: Border.all(
                                    color: Color(0xff0057d9),
                                    width: 1.w,
                                  ),
                                ),
                                child: (Text(
                                  entry.value['name'].toString(),
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showSubStationDialogVisible = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  side: const BorderSide(width: 1, color: Color(0xFF2667FF)),
                ),
                child: Text('取消', style: TextStyle(color: Colors.white)),
              ),
              OutlinedButton(
                onPressed: () async {
                  if (subStationSelect['id'] != null) {
                    stationSelect = subStationSelect; // 将子岗位设置为当前选择的岗位
                    // Navigator.of(
                    //   subStationDialogContext,
                    // ).pop(); // 移除此行，由onConfirm处理弹窗关闭
                    await handleOk();
                  } else {
                    EasyLoading.showError('请选择一个子岗位');
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  side: const BorderSide(width: 1, color: Color(0xFF2667FF)),
                  backgroundColor: Color.fromRGBO(0, 94, 236, 0.44),
                ),
                child: Text('确认', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      );
    }

    return Stack(
      children: [
        Container(
          width: 1920.h,
          height: 1080.w,
          padding: const EdgeInsets.only(left: 57, right: 57),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/login-bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          // color: Colors.blue,
          child: Column(
            children: [
              Container(
                width: 1806.w,
                height: 108.h,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/login-title.png'),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 146.h),
                  height: 570.h,
                  width: 820.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF0057D9), width: 1),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.02.sw,
                    vertical: 0.04.sh,
                  ),
                  child: Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectionWidget(
                        title: "产线选择",
                        dataList: lineList,
                        activeIndex: activeLineIndex,
                        onTap: (entry) {
                          setState(() {
                            activeLineIndex = entry.key;
                            lineSelect = entry.value;
                            stationList = lineSelect['stationList'] ?? [];
                            stationSelect = {}; // 清空岗位选择
                            subStationSelect = {}; // 清空子岗位选择
                            if (stationList.isNotEmpty) {
                              stationSelect = stationList[0];
                            }
                          });
                        },
                        displayKey: "name",
                      ),
                      SelectionWidget(
                        title: "岗位选择",
                        dataList: stationList,
                        activeIndex: activeStationIndex,
                        onTap: (entry) => {
                          setState(() {
                            activeStationIndex = entry.key;
                            stationSelect = entry.value;
                            subStationList =
                                stationSelect['childStationList'] ?? [];
                            subStationSelect = {};
                            if (subStationList.isNotEmpty) {
                              setState(() {
                                _showSubStationDialogVisible = true;
                              });
                            }
                          }),
                        },
                        displayKey: "name",
                      ),
                      OverflowBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          Offstage(
                            offstage:
                                userModel.token != '' &&
                                userModel.info['lineId'].isNotEmpty &&
                                userModel.info['stationId'].isNotEmpty,
                            child: OutlinedButton(
                              onPressed: () async {
                                userModel.clear();
                              },
                              style: OutlinedButton.styleFrom(
                                // fixedSize: Size(100.w, 54.h),
                                padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 18.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF2667FF),
                                ),
                                backgroundColor: Color.fromRGBO(
                                  0,
                                  94,
                                  236,
                                  0.44,
                                ),
                              ),
                              child: Text(
                                '返回',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 50.w),
                          OutlinedButton(
                            onPressed: () async {
                              initPage();
                            },
                            style: OutlinedButton.styleFrom(
                              // fixedSize: Size(100.w, 54.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 18.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFF2667FF),
                              ),
                              backgroundColor: Color.fromRGBO(0, 94, 236, 0.44),
                            ),
                            child: Text(
                              '刷新',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: 50.w),
                          OutlinedButton(
                            onPressed: () async {
                              await handleOk();
                            },
                            style: OutlinedButton.styleFrom(
                              // fixedSize: Size(100.w, 54.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 18.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFF2667FF),
                              ),
                              backgroundColor: Color.fromRGBO(0, 94, 236, 0.44),
                            ),
                            child: Text(
                              '确认',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Visibility(
          visible: _showSubStationDialogVisible,
          child: showSubStationDialog(context),
        ),
      ],
    );
  }
}
