import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../common//dio_request.dart';
import '../../common/login_prefs.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../home/home.dart';

import 'dart:math';
import '../leftCard/index.dart';
import 'dart:async';

const tableTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 22,
);

var statusList = {
  '1': '待加工',
  '3': '正在加工',
};
var colorList = {
  '1': 0xFFFC955F,
  // '2': 0xFF18FEFE,
  '3': 0xFF18FEFE,
  // '5': 0x7DFFFFFF,
  // '6': 0xFFE43449,
};

class ManualMachining extends StatefulWidget {
  const ManualMachining({super.key});

  @override
  State<ManualMachining> createState() => _ManualMachiningState();
}

class _ManualMachiningState extends State<ManualMachining> {
  var equSelect = {};
  List equList = [];
  final ScrollController _scrollController = ScrollController();

  List<DataRow> tableList = [];
  // FocusNode _focusNode = FocusNode();
  late final UserModel _userModel;
  var resData = {};
  var myTimer;

  void startTimer() {
    // 创建周期性定时器，每500毫秒执行一次
    myTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      await getTableList();
    });
  }

  void stopTimer() {
    // 取消定时器
    if (myTimer != null) {
      myTimer.cancel();
      myTimer = null;
    }
  }

  @override
  void initState() {
    _userModel = Provider.of<UserModel>(context, listen: false);
    super.initState();
    getEquipmentList();
    getTableList();
    startTimer();
    _userModel.saveRefreshFn(() => {getEquipmentList(), getTableList()});
    _userModel.saveBeginFn(
        () async => {await beginWork(), getEquipmentList(), getTableList()});

    // _focusNode.addListener(_handleFocusChanged);
  }

  // @override
  // bool get mounted {
  //   return super.mounted;
  // }

  @override
  void deactivate() {
    // _userModel.saveBeginFn(() => {print('方法清除')});
    _userModel.saveRefreshFn(() => {print('方法清除')});
    // _focusNode.removeListener(_handleFocusChanged);
    // _focusNode.dispose();
    stopTimer();
    super.deactivate();
  }

  // void _handleFocusChanged() {
  //   if (!_focusNode.hasFocus) {
  //     print('${username.text} 失焦了');
  //     if (username.text != '') {
  //       getDetails();
  //       eleSelect = '';
  //       dropdownMenu.currentState?.onRest();
  //       dropdownMenu.currentState?.updateOptions([]);
  //     }
  //     // 在这里执行失焦时的操作
  //   }
  // }

  //提交数据
  Future submitDetails(info) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');

    print('用户信息：${infoData}');

    print('存储信息：${equSelect}');
    // var selectInfo = resData['employeeEquipmentEntityList']
    //     ?.where((item) => item['equipmentId'] == eleSelect)
    //     .toList()[0];
    // // ?.where((item) => item['equipmentId'] == eleSelect) ;

    // print('数据：${selectInfo}');

    var params = {
      'barCode': info['barCode'],
      'employeeId': infoData['employeeId'],
      'equipmentId': equSelect['id'],
      'equipmentCode': equSelect['code'],
      'equipmentName': equSelect['name'],
      'processCellId': infoData['processId'],
    };
    print('接口提交信息${params}');

    var response = await Request.post(
      "/mes-biz/api/mes/client/manualMachining/startWork",
      data: params,
    );

    if (response["success"]) {
      EasyLoading.showSuccess(response["message"]);
      if (mounted) {
        setState(() {});
      }
      return true;
    } else {
      EasyLoading.showError(response["message"]);
      return false;
    }
  }

  // //获取页面详情数据
  // Future<void> getDetails() async {
  //   var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
  //   print('用户信息：${infoData}');

  //   var params = {
  //     'barCode': username.text,
  //     'employeeId': infoData['employeeId'],
  //     'lineId': infoData['lineId'],
  //   };
  //   print('接口提交信息${params}');

  //   var response = await Request.get(
  //     "/mes-biz/api/mes/client/manualMachining/barCodeIn",
  //     params: params,
  //   );
  //   if (response["success"]) {
  //     resData = response["data"] ?? {};
  //     print('接口返回数据：${resData}');
  //     dropdownMenu.currentState
  //         ?.updateOptions(resData['employeeEquipmentEntityList']
  //             .map((item) => {
  //                   'name': item['equipmentName'] + '-' + item['equipmentCode'],
  //                   'id': item['equipmentId']
  //                 })
  //             .toList());
  //   } else {
  //     EasyLoading.showError(response["message"]);
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }
  // //获取页面详情数据
  Future<void> delTableList(obj) async {
    var params = {
      'equipmentId': obj['deviceId'],
      'barcode': obj['barcode'],
    };
    print('接口提交信息${params}');

    var response = await Request.post(
      "/mes-biz/api/mes/client/manualMachining/removeTask?barcode=${obj['barcode']}&equipmentId=${obj['deviceId']}",
    );
    if (response["success"]) {
      // resData = response["data"] ?? {};
      print('接口返回数据：${response}');

      EasyLoading.showSuccess(response["message"]);
      getTableList();
    } else {
      EasyLoading.showError(response["message"]);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getTableList() async {
    // print('获取表格数据______${DateTime.now().millisecondsSinceEpoch}');
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // print(infoData);
    // print(infoData['equipmentId']);
    // print(infoData['orgId']);

    var response = await Request.get(
        "/mes-biz/api/mes/client/manualMachining/getDeviceTask",
        params: {
          "equipmentId": infoData['equipmentId'],
          'orgId': infoData['orgId'],
        },
        isShow: false);

    if (response["success"]) {
      List resData = response["data"] ?? [];
      print('12345${resData}');
      for (var i = 0; i < resData.length; i++) {
        resData[i]['key'] = i + 1;
      }
      tableList = resData
          .map((rowdata) => DataRow.byIndex(
                  index: rowdata['key'],
                  // onSelectChanged: (value) {
                  //   print('点击${rowdata['id']}');
                  // },
                  cells: [
                    DataCell(Text(
                        rowdata['key'].toString() != 'null'
                            ? rowdata['key'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['barcode'].toString() != 'null'
                            ? rowdata['barcode'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 12.0, // 设置小圆点的宽度
                          height: 12.0, // 设置小圆点的高度
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // 设置形状为圆形
                            color: Color((rowdata['status'].toString() != 'null'
                                    ? 0xFFFC955F
                                    : colorList[rowdata['status']]) ??
                                0xFFFC955F), // 设置小圆点的颜色
                          ),
                        ),
                        SizedBox(
                          width: 8.5,
                        ),
                        Text(
                            rowdata['status'].toString() != 'null'
                                ? statusList[rowdata['status'].toString()]
                                    .toString()
                                : '待加工',
                            style: tableTextStyle)
                      ],
                    )),
                    DataCell((
                        // rowdata['status'].toString() == '3'
                        //   ? Text('-', style: tableTextStyle)
                        //   :
                        TextButton(
                      onPressed: () {
                        print('移除${rowdata['barcode']}');
                        delTableList(rowdata);
                      },
                      child: const Text('移除', style: tableTextStyle),
                      style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return Colors.transparent;
                            },
                          ),
                          textStyle: const MaterialStatePropertyAll(
                              TextStyle(color: Colors.white))),
                    ))),
                  ]))
          .toList();
      setState(() {});
      // equList = resData
      //     .map((e) => ({'id': e['id'], 'name': e['name'], 'code': e['code']}))
      //     .toList();

      // setState(() {
      //   equSelect = {
      //     'id': infoData['equipmentId'],
      //     'name': infoData['equipmentName'],
      //     'code': infoData['equipmentCode']
      //   };
      // });
    } else {
      if (response['code'] == '777') {
      } else {
        EasyLoading.showError('${response['message']}');
      }
    }
  }

  Future<void> getEquipmentList() async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print(infoData);
    var response = await Request.post("/mes-eam/equipment/page",
        data: {"size": 500, 'current': 1, 'positionId': infoData['stationId']},
        isShow: false);

    if (response["success"]) {
      var resData = response["data"]['records'] ?? [];
      print('12345${response}');
      equList = resData
          .map((e) => ({'id': e['id'], 'name': e['name'], 'code': e['code']}))
          .toList();

      setState(() {
        equSelect = {
          'id': infoData['equipmentId'],
          'name': infoData['equipmentName'],
          'code': infoData['equipmentCode']
        };
      });
    } else {
      EasyLoading.showError('${response['message']}');
    }
  }

  Future<void> beginWork() async {
    print('${eleSelect}${username.text}确认');
    if (equSelect['id'] != null &&
        equSelect['id'] != '' &&
        _userModel.barcodeinfo['barCode'] != null) {
      var responseBool = await submitDetails(_userModel.barcodeinfo);
      if (responseBool) {
        _userModel.setBarcodeinfo({});
      }
    } else {
      EasyLoading.showError('自动提交人工机加失败');
    }
  }

  TextEditingController username = TextEditingController();
  GlobalKey<_DropdownMenuNode1State> dropdownMenu =
      GlobalKey<_DropdownMenuNode1State>();
  String eleSelect = '';

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Container(
      width: 1340,
      height: 780,
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                userModel.setBarcodeinfo({});
                userModel.setInfo({'processId': '', 'positionId': ''});
                userModel.setActiveIndex(0);
              },
              child: const Text('切换设备',
                  style: TextStyle(
                      color: Color.fromARGB(153, 255, 255, 255), fontSize: 28)),
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Colors.transparent;
                    },
                  ),
                  textStyle: const MaterialStatePropertyAll(
                      TextStyle(color: Colors.white))),
            )
          ],
        ),
        Container(
          width: 1440,

          // padding: const EdgeInsets.all(20),
          child: Column(children: [
            // SizedBox(
            //   height: 50,
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(
                //   height: 75,
                //   child: Text('           *  ',
                //       style: TextStyle(
                //         fontWeight: FontWeight.w500,
                //         fontSize: 12,
                //         color: Colors.red,
                //       )),
                // ),
                // Container(
                //   height: 75,
                //   margin: const EdgeInsets.only(right: 20),
                //   child: const Text(
                //     '设备:',
                //     style: TextStyle(
                //       color: Color(0xffC1D3FF),
                //       fontSize: 24,
                //     ),
                //   ),
                // ),
                Container(
                    width: 1000,
                    height: 100,
                    // margin: EdgeInsets.only(top: 40),
                    // color: Colors.white,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0, // 主轴(水平)方向间距
                        runSpacing: 20.0, // 纵轴（垂直）方向间距
                        alignment: WrapAlignment.start, //沿主轴方向居中
                        children: equList
                            .map((rowdata) => InkWell(
                                  onTap: () {
                                    print(rowdata['id']);
                                    final userinfo = jsonDecode(
                                        LoginPrefs.getUserInfo() ?? '');
                                    setState(() {
                                      equSelect['id'] = rowdata['id']!;
                                      equSelect['name'] = rowdata['name']!;
                                      equSelect['code'] = rowdata['code']!;
                                    });
                                    userinfo['equipmentId'] = equSelect['id'];
                                    userinfo['equipmentName'] =
                                        equSelect['name'];
                                    userinfo['equipmentCode'] =
                                        equSelect['code'];
                                    LoginPrefs.saveUserInfo(
                                        jsonEncode(userinfo));
                                    userModel.setInfo({
                                      'processId': userModel.info['processId'],
                                      'positionId':
                                          userModel.info['positionId'],
                                      'equipmentId': equSelect,
                                    });
                                    userModel.refreshfocus();
                                    // getTableList();
                                    // print(userModel.info);
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
                    ))
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: const Text(
                    '加工队列',
                    style: TextStyle(
                      color: Color(0xffC1D3FF),
                      fontSize: 24,
                    ),
                  ),
                )
              ],
            ),

            SizedBox(
              width: 1340,
              height: 560,
              child: Scrollbar(
                controller: _scrollController,
                // showTrackOnHover: true,

                /// 滚动条的宽度
                thickness: 12,

                /// 滚动条两端的圆角半径
                radius: const Radius.circular(11),

                /// 是否显示滚动条滑块
                thumbVisibility: true,

                /// 是否显示滚动条轨道
                trackVisibility: false,
                child: SingleChildScrollView(
                    padding: EdgeInsets.only(right: 20),
                    controller: _scrollController,
                    child: DataTable(
                        showCheckboxColumn: false,
                        headingRowHeight: 62,
                        dataRowMinHeight: 62,
                        dataRowMaxHeight: 62,
                        border: TableBorder.all(
                          color: Color(0xff001b44),
                          width: 2,
                        ),
                        dataRowColor: MaterialStateColor.resolveWith(
                            (states) => const Color.fromARGB(45, 31, 94, 255)),
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => const Color.fromARGB(170, 0, 102, 255)),
                        headingTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        columns: const [
                          DataColumn(
                              label: Text(
                            '序号',
                          )),
                          DataColumn(label: Text('产品件号')),
                          DataColumn(label: Text('加工状态')),
                          DataColumn(label: Text('操作')),
                        ],
                        rows: tableList)),
              ),
            ),

            // SizedBox(
            //   height: 20,
            // ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Container(
            //       height: 75,
            //       margin: const EdgeInsets.only(right: 20),
            //       child: const Text(
            //         '上一工序:',
            //         style: TextStyle(
            //           color: Color(0xffC1D3FF),
            //           fontSize: 24,
            //         ),
            //       ),
            //     ),
            //     Text(
            //       userModel.barcodeinfo['lastProcess']?['name'] != null
            //           ? userModel.barcodeinfo['lastProcess']['code'] +
            //               '-' +
            //               userModel.barcodeinfo['lastProcess']['name']
            //           : '-',
            //       style: TextStyle(
            //         color: Color(0xffC1D3FF),
            //         fontSize: 24,
            //       ),
            //     )
            //   ],
            // ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Container(
            //       height: 75,
            //       margin: const EdgeInsets.only(right: 20),
            //       child: const Text(
            //         '下一工序:',
            //         style: TextStyle(
            //           color: Color(0xffC1D3FF),
            //           fontSize: 24,
            //         ),
            //       ),
            //     ),
            //     Text(
            //       userModel.barcodeinfo['nextProcess']?['name'] != null
            //           ? userModel.barcodeinfo['nextProcess']['code'] +
            //               '-' +
            //               userModel.barcodeinfo['nextProcess']['name']
            //           : '-',
            //       style: TextStyle(
            //         color: Color(0xffC1D3FF),
            //         fontSize: 24,
            //       ),
            //     )
            //   ],
            // ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Container(
            //       height: 75,
            //       margin: const EdgeInsets.only(right: 20),
            //       child: const Text(
            //         '       状态:',
            //         style: TextStyle(
            //           color: Color(0xffC1D3FF),
            //           fontSize: 24,
            //         ),
            //       ),
            //     ),
            //     Text(
            //       '合格',
            //       style: TextStyle(
            //         color: Color(0xffC1D3FF),
            //         fontSize: 24,
            //       ),
            //     )
            //   ],
            // ),
            // Row(
            //   children: [
            //     ButtonBar(
            //       alignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            // OutlinedButton(
            //     onPressed: () {
            //       print('${username.text}评审');
            //       username.clear();
            //       // print(dropdownMenu.currentState?.onRest);
            //       dropdownMenu.currentState?.onRest();
            //       dropdownMenu.currentState?.updateOptions([]);
            //       resData = {};
            //       setState(() {});
            //       // showDialogFunction(
            //       //   context,
            //       // );
            //     },
            //     style: OutlinedButton.styleFrom(
            //         fixedSize: const Size(180, 54),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(3),
            //         ),
            //         side: const BorderSide(
            //             width: 1, color: Color(0xff0085ff)),
            //         backgroundColor:
            //             const Color.fromARGB(23, 0, 133, 255)),
            //     child: const Text(
            //       '重置',
            //       style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 26,
            //           fontWeight: FontWeight.w700),
            //     )),
            // SizedBox(
            //   width: 200,
            // ),
            // OutlinedButton(
            //     onPressed: () async {
            //       await beginWork();
            //       // print('${eleSelect}${username.text}确认');
            //       // if (equSelect['id'] != null &&
            //       //     equSelect['id'] != '' &&
            //       //     userModel.barcodeinfo['barCode'] != null) {
            //       //   var responseBool =
            //       //       await submitDetails(userModel.barcodeinfo);
            //       //   if (responseBool) {
            //       //     userModel.setBarcodeinfo({});
            //       //   }
            //       // } else {
            //       //   EasyLoading.showError('请输入必填项');
            //       // }
            //     },
            //     style: OutlinedButton.styleFrom(
            //         fixedSize: const Size(180, 54),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(3),
            //         ),
            //         side: const BorderSide(
            //             width: 1, color: Color(0xff52fefe)),
            //         backgroundColor:
            //             const Color.fromARGB(20, 0, 222, 236)),
            //     child: const Text(
            //       '开始作业',
            //       style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 26,
            //           fontWeight: FontWeight.w700),
            //     ))
            // ],
            // )
            // ],
            // )
          ]),
          // color: Colors.red,
        )
      ]),
    );
  }
}

OutlineInputBorder _outlineInputBorder = const OutlineInputBorder(
  gapPadding: 0,
  borderSide: BorderSide(
    color: Color(0xff4b74dc),
  ),
);

Widget usernameInput(TextEditingController username, _focusNode) {
  return SizedBox(
      width: 460,
      height: 100,
      child: TextFormField(
        controller: username,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '请扫描或输入',
          hintStyle: TextStyle(color: Color(0xffC1D3FF)),
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
        focusNode: _focusNode,
        onSaved: (v) => username.text = v!,
      ));
}

class DropdownMenuNode1 extends StatefulWidget {
  const DropdownMenuNode1({super.key, required this.onChanged});
  final Function onChanged;

  @override
  State<DropdownMenuNode1> createState() => _DropdownMenuNode1State();
}

class _DropdownMenuNode1State extends State<DropdownMenuNode1> {
  List data = [];
  String? _dropdownValue = null;
  void updateOptions(list) {
    // 动态更新选项列表的示例
    setState(() {
      data = list ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_dropdownValue);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 460,
          height: 54,
          margin: EdgeInsets.only(bottom: 5, left: 5),
          padding: EdgeInsets.only(top: 5, bottom: 3, left: 10, right: 15),
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xff4b74dc), width: 1),
              borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(4, 4),
                  bottom: Radius.elliptical(4, 4))),
          child: DropdownButton(
            menuMaxHeight: 200, //设置下拉框高度
            dropdownColor: Color(0xff0E175B), // 设置下拉框颜色
            isExpanded: true,
            underline: Container(color: Colors.white),
            hint: Text(
              "请选择设备",
              style: TextStyle(color: Color(0xffC1D3FF)),
            ),
            value: _dropdownValue,
            items: data.map((value) {
              return DropdownMenuItem<String>(
                value: value?['id'],
                child: Container(
                  child: Text(
                    value?['name'],
                    style: TextStyle(color: Color(0xffC1D3FF), fontSize: 18),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              widget.onChanged(value);
              _dropdownValue = value!;
              setState(() {});
            },
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _onSelect(String? value) {
    widget.onChanged(value);
    setState(() {
      _dropdownValue = value!;
    });
  }

  void onRest() {
    setState(() {
      print('情空');
      _dropdownValue = null;
      // _dropdownValue = '';
    });
  }
}
