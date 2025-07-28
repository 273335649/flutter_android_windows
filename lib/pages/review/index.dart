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

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  // final GlobalKey<FormState> form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return
        // userModel.childToken != ''
        //     ?
        const ReviewContent();
    // : const ChildLogin(title: '欢迎使用不合格评审功能');
  }
}

//输入框确认按钮
OutlineInputBorder _outlineInputBorder = const OutlineInputBorder(
  gapPadding: 0,
  borderSide: BorderSide(
    color: Color(0xff4b74dc),
  ),
);

class ReviewContent extends StatefulWidget {
  const ReviewContent({super.key});

  @override
  State<ReviewContent> createState() => _ReviewContentState();
}

class _ReviewContentState extends State<ReviewContent> {
  TextEditingController username = TextEditingController();
  var activeIndex;
  late final UserModel _userModel;
  void changeActiveIndex(index) {
    activeIndex = index;
    print(activeIndex);
  }

  Future submitDetail(rowdata, conclusion) async {
    print('列表数据:${rowdata}');
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${infoData}');
    // var infochildData = jsonDecode(LoginPrefs.getChildUserInfo() ?? '');

    print('不合格情况：${selectDefect}');
    var defectImgList;
    if (conclusion == 0) {
      defectImgList =
          pictureList.where((item) => item['select'] ?? false).map((item) {
        return {
          'attachmentName': item['attachmentName'],
          'attachmentUrl': item['url']
        };
      }).toList();
    }
    print('conclusion$conclusion');
    print('defectImgList:$defectImgList');
    var params = {
      "barCode": rowdata['barcode'],
      "defectCode": conclusion == 1 ? null : selectDefect['code'],
      "employeeId": infoData['employeeId'],
      "employeeNo": infoData['employeeNo'],
      "employeeName": infoData['employeeName'],
      "lineCode": infoData['lineCode'],
      "lineId": infoData['lineId'],
      "lineName": infoData['lineName'],
      "processCode": infoData['processCode'],
      "processId": infoData['processId'],
      "processName": infoData['processName'],
      "reviewRecordId": rowdata['id'],
      "reviewResult": conclusion == 1 ? 1 : 2,
      "stationId": infoData['stationId'],
      "stationName": infoData['stationName'],
      'defectImgList': conclusion == 0 ? defectImgList : null
    };
    print('接口提交信息${params}');

    var response = await Request.post(
      "/mes-biz/api/mes/client/task/reviewHandle",
      data: params,
      // isChildToken: true
    );
    if (response["success"]) {
      // var resData = response["data"] ?? {};

      EasyLoading.showSuccess(response["message"]);
      getDetails();
      print(response);
      activeIndex = null;

      return true;
    } else {
      EasyLoading.showError(response["message"]);
      return false;
    }
  }

  //获取页面详情数据
  List<DataRow> dataSource = [];
  var responseList = [];

  Future<void> getDetails() async {
    var statusList = {
      '1': '待评审',
      '2': '完结',
    };
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('用户信息：${infoData}');

    var params = {
      'barCode': username.text,
    };
    print('接口提交信息${params}');

    var response = await Request.get(
      "/mes-biz/api/mes/client/task/queryReviewByBarCode",
      params: params,
      // isChildToken: true,
    );
    if (response["success"]) {
      List resData = response["data"] ?? [];
      print('接口返回数据：${resData}');
      responseList = resData;
      dataSource = resData
          .map((rowdata) => DataRow.byIndex(
                  index: int.tryParse(rowdata['id']),
                  onSelectChanged: (value) {
                    print('点击${rowdata}');

                    selectDefect = {};
                    activeIndex = null;
                    var materialInfo = {
                      'materialCode': rowdata['materialCode'],
                      'materialId': rowdata['materialId'],
                      'materialName': rowdata['materialName']
                    };
                    LoginPrefs.saveMaterialInfo(jsonEncode(materialInfo));

                    showDialogFunction(context, {
                      'width': 1144.0,
                      'height': 500.0,
                      'title': '确认提示',
                      'okText': '确定',
                      'disableClose': true,
                      'onSubmit': () {
                        if (activeIndex == 0) {
                          Navigator.of(context).pop();
                          showDialogFunction(context, {
                            'title': '不合格上报',
                            'width': 1144.0,
                            'content': ModalSelect(),
                            // 'disableClose': true,
                            'onSubmit': () {
                              print(activeIndex);
                              if (selectDefect['id'] != null) {
                                Navigator.of(context).pop();
                                showDialogFunction(context, {
                                  'title': '缺陷标记',
                                  'width': 1050.0,
                                  'content': ModalPicture(),
                                  'onSubmit': () {
                                    return submitDetail(rowdata, 0);
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
                          return true;
                        } else if (activeIndex == 1) {
                          Navigator.of(context).pop();
                          return submitDetail(rowdata, 1);
                        } else {
                          EasyLoading.showError('请输入必填项');
                          return false;
                        }
                        // return submitDetails(subitem);
                      },
                      'onCancel': () {
                        activeIndex = null;
                        print(activeIndex);
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
                                    color: const Color(0x331F5EFF),
                                    height: 64,
                                    padding: const EdgeInsets.only(
                                        left: 24, top: 17),
                                    child: const Text(
                                      '产品件号:',
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
                                      padding: const EdgeInsets.only(
                                          left: 24, top: 17),
                                      child: Text(
                                        rowdata['barcode'].toString(),
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
                                    padding: const EdgeInsets.only(
                                        left: 24, top: 17),
                                    child: const Text(
                                      '生产工序:',
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
                                      padding: const EdgeInsets.only(
                                          left: 24, top: 17),
                                      child: Text(
                                        rowdata['processCellCode'].toString() +
                                            '-' +
                                            rowdata['processCellName']
                                                .toString(),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    color: const Color(0x331F5EFF),
                                    height: 64,
                                    padding: const EdgeInsets.only(
                                        left: 24, top: 17),
                                    child: const Text(
                                      '状态:',
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
                                      padding: const EdgeInsets.only(
                                          left: 24, top: 17),
                                      child: Text(
                                        rowdata['status'].toString() == '1'
                                            ? '待评审'
                                            : '完结',
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
                                    padding: const EdgeInsets.only(
                                        left: 24, top: 17),
                                    child: const Text(
                                      '生产设备:',
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
                                      padding: const EdgeInsets.only(
                                          left: 24, top: 17),
                                      child: Text(
                                        rowdata['productEquipmentCode']
                                                .toString() +
                                            '-' +
                                            rowdata['productEquipmentName']
                                                .toString(),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    color: const Color(0x331F5EFF),
                                    height: 64,
                                    padding: const EdgeInsets.only(
                                        left: 24, top: 17),
                                    child: const Text(
                                      '申请人:',
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
                                      padding: const EdgeInsets.only(
                                          left: 24, top: 17),
                                      child: Text(
                                        rowdata['applicantName'].toString(),
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
                                    padding: const EdgeInsets.only(
                                        left: 24, top: 17),
                                    child: const Text(
                                      '申请时间:',
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
                                      padding: const EdgeInsets.only(
                                          left: 24, top: 17),
                                      child: Text(
                                        rowdata['applicantTime'].toString(),
                                        style: const TextStyle(
                                          color: Color(0xffC1D3FF),
                                          fontSize: 24,
                                        ),
                                      )),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 75,
                                  child: Text('*  ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: Colors.red,
                                      )),
                                ),
                                Container(
                                  height: 75,
                                  margin: const EdgeInsets.only(right: 20),
                                  child: const Text(
                                    '处理结果:',
                                    style: TextStyle(
                                      color: Color(0xffC1D3FF),
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            MyBtnGroup(
                                changeActiveIndex: changeActiveIndex,
                                activeIndex: activeIndex),
                          ])
                    });
                  },
                  cells: [
                    DataCell(Text(
                        rowdata['barcode'].toString() != 'null'
                            ? rowdata['barcode'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['processCellCode'].toString() != 'null'
                            ? '${rowdata['processCellCode']}-${rowdata['processCellName']}'
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['status'].toString() != 'null'
                            ? statusList[rowdata['status'].toString()]
                                .toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['applicantName'].toString() != 'null'
                            ? rowdata['applicantName'].toString()
                            : '-',
                        style: tableTextStyle)),
                    DataCell(Text(
                        rowdata['applicantTime'].toString() != 'null'
                            ? rowdata['applicantTime'].toString()
                            : '-',
                        style: tableTextStyle)),
                  ]))
          .toList();
      username.clear();
    } else {
      EasyLoading.showError(response["message"]);
      print(response["message"]);
      _userModel.setChildToken('');
      username.clear();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    getDetails();
    // TODO: implement initState
    _userModel = Provider.of<UserModel>(context, listen: false);

    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  Future<void> changeText() async {
    await getDetails();
    print('执行弹窗打开${responseList}');
    if (responseList.isNotEmpty) {
      selectDefect = {};
      activeIndex = null;
//扫码成功自动打开默认第一条弹窗
      showDialogFunction(context, {
        'width': 1144.0,
        'height': 500.0,
        'title': '确认提示',
        'okText': '确定',
        'disableClose': true,
        'onSubmit': () {
          if (activeIndex == 0) {
            Navigator.of(context).pop();
            showDialogFunction(context, {
              'title': '不合格上报',
              'width': 1144.0,
              'content': ModalSelect(),
              // 'disableClose': true,
              'onSubmit': () {
                // print(activeIndex);
                // return submitDetail(responseList[0], activeIndex);
                print(activeIndex);
                if (selectDefect['id'] != null) {
                  Navigator.of(context).pop();
                  showDialogFunction(context, {
                    'title': '缺陷标记',
                    'width': 1050.0,
                    'content': ModalPicture(),
                    'onSubmit': () {
                      return submitDetail(responseList[0], 0);
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
            return true;
          } else if (activeIndex == 1) {
            Navigator.of(context).pop();
            return submitDetail(responseList[0], 1);
          } else {
            EasyLoading.showError('请输入必填项');
            return false;
          }
          // return submitDetails(subitem);
        },
        'onCancel': () {
          activeIndex = null;
          print(activeIndex);
        },
        'content':
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    '产品件号:',
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
                      responseList[0]['barcode'].toString(),
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
                    '生产工序:',
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
                      responseList[0]['processCellCode'].toString() +
                          '-' +
                          responseList[0]['processCellName'].toString(),
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
                    '状态:',
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
                      responseList[0]['status'].toString() == '1'
                          ? '待评审'
                          : '完结',
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
                    '生产设备:',
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
                      responseList[0]['productEquipmentCode'].toString() +
                          '-' +
                          responseList[0]['productEquipmentName'].toString(),
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
                    '申请人:',
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
                      responseList[0]['applicantName'].toString(),
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
                    '申请时间:',
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
                      responseList[0]['applicantTime'].toString(),
                      style: const TextStyle(
                        color: Color(0xffC1D3FF),
                        fontSize: 24,
                      ),
                    )),
              )
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 75,
                child: Text('*  ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.red,
                    )),
              ),
              Container(
                height: 75,
                margin: const EdgeInsets.only(right: 20),
                child: const Text(
                  '处理结果:',
                  style: TextStyle(
                    color: Color(0xffC1D3FF),
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          MyBtnGroup(
              changeActiveIndex: changeActiveIndex, activeIndex: activeIndex),
        ])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    // final infoChildData = jsonDecode(LoginPrefs.getChildUserInfo() ?? '');
    // TextEditingController searchValue = TextEditingController();
    return Container(
      width: 1340,
      height: 780,
      padding: const EdgeInsets.all(20),
      // color: Colors.red,
      child: Column(children: [
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 320,
              height: 48,
              padding: const EdgeInsets.only(left: 10, right: 22),
              child: usernameInput(username, changeText),
            ),
            Row(
              children: [
                // Text(
                //   '操作人:${userModel.childInfo['name']} |',
                //   style: const TextStyle(
                //       color: Color.fromARGB(153, 255, 255, 255)),
                // ),
                // TextButton(
                //   onPressed: () {
                //     userModel.setChildToken('');
                //     LoginPrefs.removeChildToken();
                //     LoginPrefs.removeChildUserInfo();
                //   },
                //   child: const Text('退出登录',
                //       style:
                //           TextStyle(color: Color.fromARGB(153, 255, 255, 255))),
                //   style: ButtonStyle(
                //       overlayColor: MaterialStateProperty.resolveWith<Color>(
                //         (Set<MaterialState> states) {
                //           return Colors.transparent;
                //         },
                //       ),
                //       textStyle: const MaterialStatePropertyAll(
                //           TextStyle(color: Colors.white))),
                // )
              ],
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          height: 650,
          width: 1340,
          child: SingleChildScrollView(
              child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 64,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 64,
                  border: TableBorder.all(
                      color: const Color.fromARGB(255, 0, 16, 48), width: 2),
                  dataRowColor: MaterialStateColor.resolveWith(
                      (states) => const Color.fromARGB(45, 31, 94, 255)),
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => const Color.fromARGB(170, 0, 102, 255)),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  columns: const [
                    DataColumn(
                        label: SizedBox(
                      width: 300,
                      child: Text('产品件号'),
                    )),
                    DataColumn(label: Text('生产工序')),
                    DataColumn(label: Text('状态')),
                    DataColumn(label: Text('申请人')),
                    DataColumn(label: Text('申请时间')),
                  ],
                  rows: dataSource)),
        ),
        // Text(
        //   '123',
        //   style: TextStyle(color: Colors.red),
        // )
      ]),
    );
  }
}

const tableTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 22,
);

class MyBtnGroup extends StatefulWidget {
  const MyBtnGroup({super.key, this.activeIndex, this.changeActiveIndex});
  final activeIndex;
  final changeActiveIndex;

  @override
  State<MyBtnGroup> createState() => _MyBtnGroupState();
}

class _MyBtnGroupState extends State<MyBtnGroup> {
  var activeIndex;
  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
            onPressed: () {
              widget.changeActiveIndex(0);
              setState(() {
                activeIndex = 0;
              });
              //调取不合格列表
            },
            style: OutlinedButton.styleFrom(
                fixedSize: const Size(534, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                side: const BorderSide(width: 1, color: Color(0xffb52929)),
                // shadowColor: Color.fromARGB(135, 0, 133, 255),
                // elevation: 5.0,
                backgroundColor: activeIndex == 0
                    ? Color.fromARGB(200, 245, 46, 46)
                    : Color.fromARGB(40, 245, 46, 46)),
            child: const Text(
              '不合格',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
            )),
        OutlinedButton(
            onPressed: () {
              widget.changeActiveIndex(1);
              setState(() {
                activeIndex = 1;
              });
            },
            style: OutlinedButton.styleFrom(
                fixedSize: const Size(534, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                side: const BorderSide(width: 1, color: Color(0xff52fefe)),
                backgroundColor: activeIndex == 1
                    ? const Color.fromARGB(200, 0, 222, 236)
                    : const Color.fromARGB(20, 0, 222, 236)),
            child: const Text(
              '合格',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
            ))
      ],
    );
  }
}

Widget usernameInput(TextEditingController username, changeText) {
  return SizedBox(
      width: 460,
      height: 100,
      child: TextFormField(
        controller: username,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '请扫描或输入',
          hintStyle: const TextStyle(color: Color(0xffC1D3FF)),
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
        onChanged: (value) async {
          if (value.length >= 25) {
            changeText();
          }
        },
        // focusNode: _focusNode,
        onSaved: (v) => username.text = v!,
      ));
}
