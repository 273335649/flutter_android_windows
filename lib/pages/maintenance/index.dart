import 'package:flutter/material.dart';
import '../../common//dio_request.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hc_mes_app/common/login_prefs.dart';
import 'dart:convert';
import '../leftCard/index.dart';

class Maintenance extends StatefulWidget {
  const Maintenance({super.key});

  @override
  State<Maintenance> createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  // late final ScrollController _scrollController;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1340,
        height: 780,
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
        ),
        child: MyTable());
  }
}

class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  var current = 1;
  var total = 0;
  var submitItems;
  var detailData;
  List<DataRow> dataSource = [];

  void changeItems(items) {
    submitItems = items;
    print('外部打印${items}');
  }

  void closeModal() {
    // Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> getTableData() async {
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');

    print(finalData['lineCode']);
    var response = await Request.post("/mes-eam/maintain/task/page-biz",
        isShow: false, data: {"size": 10, 'current': current});

    if (response["success"]) {
      List resData = response["data"]['records'] ?? [];
      total = response["data"]['total'];
      current = response["data"]['current'];
      print('查看接口数据 ${response}');
      dataSource = resData
          .map((rowdata) => DataRow.byIndex(
                  index: int.tryParse(rowdata['id']),
                  onSelectChanged: (value) async {
                    print('点击${rowdata['items']}');
                    var items = await getDetail(rowdata['id']);
                    showDialogFunction(context, {
                      'width': 1144.0,
                      'height': 500.0,
                      'title': '执行维保',
                      'okText': '确定',
                      'content': ModalContent(
                          rowdata: items, changeItems: changeItems),
                      'onSubmit': () {
                        return submitDetail(rowdata, 1);
                      },
                      'expentBtn': OutlinedButton(
                          onPressed: () {
                            closeModal();
                            print('维保异常');
                            showDialogFunction(context, {
                              'width': 1144.0,
                              'height': 500.0,
                              'title': '设备异常呼叫',
                              'okText': '异常完结',
                              'content': MaintenanceModal(),
                              'onSubmit': () {
                                return submitDetail(rowdata, 2);
                              },
                            });
                          },
                          style: OutlinedButton.styleFrom(
                              fixedSize: Size(152, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              side: const BorderSide(
                                  width: 1, color: Color(0xffb52929)),
                              // shadowColor: Color.fromARGB(135, 0, 133, 255),
                              // elevation: 5.0,
                              backgroundColor:
                                  const Color.fromARGB(40, 245, 46, 46)),
                          child: Text(
                            '维保异常',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          )),
                    });
                  },
                  cells: [
                    DataCell(Text(
                        rowdata['taskCode'].toString() != 'null'
                            ? rowdata['taskCode'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['equipmentCode'].toString() != 'null'
                            ? rowdata['equipmentCode'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['equipmentName'].toString() != 'null'
                            ? rowdata['equipmentName'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['planMaintainTime'].toString() != 'null'
                            ? rowdata['planMaintainTime'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['taskStatusFormat'].toString() != 'null'
                            ? rowdata['taskStatusFormat'].toString()
                            : '-',
                        style: tableTextStyle)),
                    // DataCell(Text(
                    //     rowdata['rawSendNum'].toString() != 'null'
                    //         ? rowdata['rawSendNum'].toString()
                    //         : '-',
                    //     style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['personNames'].toString() != 'null'
                            ? rowdata['personNames'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['maintainFormat'].toString() != 'null'
                            ? rowdata['maintainFormat'].toString()
                            : '-',
                        style: tableTextStyle)),
                  ]))
          .toList();

      setState(() {});
    } else {
      EasyLoading.showError('${response['message']}');
    }
  }

  Future getDetail(id) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${infoData}');
    // print('列表详情：${rowdata}');

    var params = {
      "id": id,
    };
    print('接口提交信息${params}');

    var response =
        await Request.get("/mes-eam/maintain/task/detail", params: params);
    if (response["success"]) {
      // var resData = response["data"] ?? {};

      print(response);
      detailData = response['data'];

      return response['data'];
    } else {
      EasyLoading.showError(response["message"]);
      return {};
    }
  }

  Future submitDetail(rowdata, maintainStatus) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${infoData}');
    print('列表详情：${submitItems}');
    var newitems = submitItems
        .map((item) => {
              "description": item['description'],
              "name": item['description'],
              "remark": item['remark'],
              "result": item['submit'] == true ? '已保养' : '未保养'
            })
        .toList();
    var params = {
      "attachment": detailData['attachment'],
      "id": rowdata['id'],
      "items": newitems,
      "maintainStatus": maintainStatus
    };
    print('接口提交信息${params}');

    var response =
        await Request.post("/mes-eam/maintain/task/maintain", data: params);
    if (response["success"]) {
      // var resData = response["data"] ?? {};

      EasyLoading.showSuccess(response["message"]);
      print(response);

      getTableData();
      return true;
    } else {
      EasyLoading.showError(response["message"]);
      return false;
    }
  }

  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    getTableData();
    super.initState();
    _scrollController.addListener(() {
      // 当滚动位置改变时，这个回调会被触发
      double offset = _scrollController.offset;
      // 使用offset做你需要的操作
    });
  }

  @override
  void deactivate() {
    _scrollController.dispose(); // 释放资源
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
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
            trackVisibility: true,
            child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20),
                // primary: true,
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    showCheckboxColumn: false,
                    headingRowHeight: 62,
                    dataRowMinHeight: 62,
                    dataRowMaxHeight: 62,
                    border: TableBorder.all(color: Color(0xff001b44), width: 2),
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
                          label: SizedBox(
                        width: 200,
                        child: Text(
                          '任务编码',
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 200,
                        child: Text(
                          '设备编码',
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 200,
                        child: Text(
                          '设备名称',
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 200,
                        child: Text(
                          '设备维保时间',
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 150,
                        child: Text(
                          '状态',
                        ),
                      )),
                      // DataColumn(
                      //     label: SizedBox(
                      //   width: 300,
                      //   child: Text(
                      //     '维保班组',
                      //   ),
                      // )),
                      DataColumn(
                          label: SizedBox(
                        width: 300,
                        child: Text(
                          '执行人选',
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 100,
                        child: Text(
                          '已维保项',
                        ),
                      )),
                    ],
                    rows: dataSource)),
          )),
          Container(
            width: 1340,
            height: 56,
            padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
            color: Color.fromARGB(45, 31, 94, 255),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '共${total}条',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      color: Color(0xffc54a1ff),
                      icon: Icon(Icons.chevron_left),
                      onPressed: () {
                        print('上一页');
                        if (current > 1) {
                          current = current - 1;
                          setState(() {
                            getTableData();
                          });
                        }
                      },
                    ),
                    Text('${current}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        )),
                    Text(
                        '/${(total / 10).ceil() == 0 ? 1 : (total / 10).ceil()}',
                        style: TextStyle(
                          color: Color.fromARGB(90, 255, 255, 255),
                          fontSize: 24,
                        )),
                    IconButton(
                      color: Color(0xffc54a1ff),
                      icon: Icon(Icons.chevron_right),
                      onPressed: () {
                        print('下一页');
                        if (current < (total / 10).ceil()) {
                          current = current + 1;
                          setState(() {
                            getTableData();
                          });
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          )
        ]);
  }
}

const tableTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 22,
);

class ModalContent extends StatefulWidget {
  const ModalContent({super.key, this.rowdata, this.changeItems});
  final rowdata;
  final changeItems;
  @override
  State<ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {
  final ScrollController _scrollController = ScrollController();
  @override
  List items = [];
  void initState() {
    // TODO: implement initState
    print('弹窗内列表：${widget.rowdata['standard']['items']}');
    items = widget.rowdata['standard']['items'] == null
        ? []
        : widget.rowdata['standard']['items'];
    for (var i = 0; i < items.length; i++) {
      items[i]['id'] = i;
      if (items[i]['result'] == '已保养') {
        items[i]['submit'] = true;
      } else {
        items[i]['submit'] = false;
      }
    }
    ;
    widget.changeItems(items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0x331F5EFF),
              height: 64,
              padding: const EdgeInsets.only(left: 24, top: 17),
              child: const Text(
                '设备编码:',
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
                color: const Color(0x661F5EFF),
                height: 64,
                padding: const EdgeInsets.only(left: 24, top: 17),
                child: Text(
                  widget.rowdata['equipmentCode'].toString(),
                  style: const TextStyle(
                    color: Color(0xffC1D3FF),
                    fontSize: 24,
                  ),
                )),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0x331F5EFF),
              height: 64,
              padding: const EdgeInsets.only(left: 24, top: 17),
              child: const Text(
                '设备名称:',
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
                color: const Color(0x661F5EFF),
                height: 64,
                padding: const EdgeInsets.only(left: 24, top: 17),
                child: Text(
                  widget.rowdata['equipmentName'].toString(),
                  style: const TextStyle(
                    color: Color(0xffC1D3FF),
                    fontSize: 24,
                  ),
                )),
          )
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      Container(
          height: 400,
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
                    headingRowHeight: 64,
                    dataRowMinHeight: 100,
                    dataRowMaxHeight: 100,
                    border: TableBorder.all(
                        color: Color.fromARGB(255, 0, 16, 48), width: 2),
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
                          label: SizedBox(
                        width: 300,
                        child: Text(
                          '维保项目',
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 550,
                        child: Text(
                          '维保标准',
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 100,
                        child: Text(
                          '维保结果',
                        ),
                      )),
                    ],
                    rows: items
                        .map((item) =>
                            DataRow.byIndex(index: item['id'], cells: [
                              DataCell(Text(
                                  item['name'].toString() != 'null'
                                      ? item['name'].toString()
                                      : '-',
                                  style: tableTextStyle)),
                              DataCell(Container(
                                width: 550,
                                child: Text(
                                    item['description'].toString() != 'null'
                                        ? item['description'].toString()
                                        : '-',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    )),
                              )),
                              DataCell(OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    item['submit'] = !item['submit'];
                                  });
                                  widget.changeItems(items);
                                },
                                style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(100, 54),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    side: const BorderSide(
                                        width: 1,
                                        color:
                                            Color.fromARGB(135, 0, 148, 255)),
                                    backgroundColor: item['submit']
                                        ? const Color.fromARGB(112, 0, 94, 236)
                                        : Color(0xFF092262)),
                                child: Text(
                                  '完成',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              )),
                            ]))
                        .toList())),
          ))
    ]);
  }
}

class MaintenanceModal extends StatefulWidget {
  const MaintenanceModal({super.key});

  @override
  State<MaintenanceModal> createState() => _MaintenanceModalState();
}

class _MaintenanceModalState extends State<MaintenanceModal> {
  Map dataList = {};

  List colorsList = [
    0x8FDC9E00,
    0x4DFF0000,
    0x6600DEEC,
    0x00000000,
    0x4DFF0000,
  ];

  //安灯呼叫
  Future<bool> submitDetails(id) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${infoData}');

    var params = {
      'eventId': id,
      'lineCode': infoData['lineCode'],
      'lineName': infoData['lineName'],
      'lineId': infoData['lineId'],
      'operatorId': infoData['employeeId'],
      'stationId': infoData['stationId'],
      'stationName': infoData['stationName'],
    };
    print('接口提交信息${params}');

    var response = await Request.post("/mes-biz/api/mes/client/andon/andonCall",
        data: params);
    if (response["success"]) {
      var resData = response["data"];

      print(response["data"]);
      print(resData);
      // dataList = resData;
      EasyLoading.showSuccess(response["message"]);
      setState(() {});
      getDetails(false);
      return true;
    } else {
      EasyLoading.showError(response["message"]);
      return false;
    }
  }

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

            print(subitem);
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

  //获取页面详情数据
  Future<void> getDetails(isShow) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${infoData}');

    var params = {
      'lineId': infoData['lineId'],
      'callEmployeeId': infoData['employeeId'],
      'isAll': true
      // 'barCode': username.text,
    };
    print('接口提交信息${params}');

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

      dataList = resData.firstWhere((item) => item['name'] == '设备异常',
          orElse: () => null);

      // print(response["data"]);
      print(dataList);
    } else {
      EasyLoading.showError(response["message"]);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getDetails(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      border: Border.all(color: Color(0xff0057d9), width: 1)),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '维保异常',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Wrap(
                spacing: 10.0, // 主轴(水平)方向间距
                runSpacing: 24.0, // 纵轴（垂直）方向间距
                alignment: WrapAlignment.start, //沿主轴方向居中
                children: defectCodeListToWidgets(
                    dataList['andonEventList'] ?? [], context)),
            SizedBox(
              height: 30,
            ),
          ]),
    );
  }
}
