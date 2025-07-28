import 'package:flutter/material.dart';
import 'package:hc_mes_app/utils/init.dart';
import '../../common/constant.dart';
import '../../common/login_prefs.dart';
import '../../widget/childLogin.dart';
import 'package:provider/provider.dart';
import '../home/home.dart';
import 'dart:convert';
import '../../common//dio_request.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import '../leftCard/index.dart';

class Unqualified extends StatefulWidget {
  const Unqualified({super.key});

  @override
  State<Unqualified> createState() => _UnqualifiedState();
}

class _UnqualifiedState extends State<Unqualified> {
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return
        // userModel.childToken != ''
        //     ?
        const UnqualifiedContent();
    // : ChildLogin(title: '欢迎使用不合格入库功能');
  }
}

class UnqualifiedContent extends StatefulWidget {
  const UnqualifiedContent({super.key});

  @override
  State<UnqualifiedContent> createState() => _UnqualifiedContentState();
}

class _UnqualifiedContentState extends State<UnqualifiedContent> {
  var resData = {};
  //提交
  Future<void> submitToMes() async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print(resData);
    var params = {
      "barCode": username.text,
      "checkEmployeeId": resData['userId'],
      "defect": resData["defectCode"],
      "materialCode": resData['materialCode'],
      "materialName": resData['materialName'],
      "lineCode": infoData['lineCode'],
      "lineId": infoData['lineId'],
      "lineName": infoData['lineName'],
    };
    print('接口提交信息1111${params}');

    var response = await Request.post(
      "/mes-biz/api/mes/client/task/syncUnqualifiedToMes",
      data: params,
      // isChildToken: true,
    );
    if (response["success"]) {
      print('接口返回数据111：${response}');
      EasyLoading.showSuccess(response["message"]);
    } else {
      EasyLoading.showError(response["message"]);
    }
    if (mounted) {
      setState(() {});
    }
  }

  //提交
  Future<void> submitDetails() async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print(infoData);
    var params = {
      // 'barCode': username.text,
      "VIN": username.text,
      "ZTBM": resData['materialCode'],
      "SCX": infoData['lineCode'],
      "WORK_FLOW": resData['stationCode'],
      "GZXX": resData["defectCode"],
      "SMRY": resData['username'],
      "CPMC": resData['materialName'],
      "SCXZX": ""
    };
    print('接口提交信息${params}');

    var response = await Request.post(
        "/jj_mes_api/v1/product/submitUnqualifiedRecord",
        data: params,
        baseUrl: Constant.zdUrl,
        isZDToken: true);
    print('接口返回数据：${response}');
    // EasyLoading.showError(response["msg"]);
    if (response["rtn"] != 0) {
      submitToMes();
    } else {
      EasyLoading.showError(response["msg"]);
    }
    if (mounted) {
      setState(() {});
    }
  }

  //登录鉴权
  Future<void> zdLogin() async {
    var password = await encodeString('Hm123456*');
    print('用户信息：${password}');
    var params = {
      // 'barCode': username.text,
      "userName": "10003",
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
    } else {
      EasyLoading.showError(response["message"]);
    }

    // print('查看存储token：${LoginPrefs.getIdentitytoken()}');
    if (mounted) {
      setState(() {});
    }
  }

  //查询信息
  Future<void> getDetail() async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    print('主用户信息${infoData}');
    // var infoChildData = jsonDecode(LoginPrefs.getChildUserInfo() ?? '');
    var params = {
      'barCode': username.text,
    };
    print('接口提交信息${params}');

    var response = await Request.get(
      "/mes-biz/api/mes/client/task/queryProductInfoByBarCode",
      params: params,
      // isChildToken: true,
    );
    if (response["success"]) {
      print('接口返回数据：${response['data']}');
      // print('用户信息${infoChildData}');
      resData = response['data'];
      resData['stationCode'] = infoData['stationCode'];
      resData['username'] = infoData['employeeName'];
      resData['userId'] = infoData['employeeId'];
      print('接口返回信息：${response}');
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
    _focusNode.addListener(_handleFocusChanged);
    super.initState();
    zdLogin();
  }

  @override
  void deactivate() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.deactivate();
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      print('${username.text} 失焦了');
      if (username.text != '') {
        getDetail();
      }
      // 在这里执行失焦时的操作
    }
  }

  TextEditingController username = TextEditingController();
  FocusNode _focusNode = FocusNode();

  bool _isChecked = false;

  void _handleCheckboxChanged(value) {
    setState(() {
      _isChecked = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Container(
      width: 1340,
      height: 780,
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     Text(
        //       '操作人:${userModel.childInfo['name']} |',
        //       style: const TextStyle(color: Color.fromARGB(153, 255, 255, 255)),
        //     ),
        //     TextButton(
        //       onPressed: () {
        //         userModel.setChildToken('');
        //         LoginPrefs.removeChildToken();
        //         LoginPrefs.removeChildUserInfo();
        //       },
        //       child: const Text('退出登录',
        //           style: TextStyle(color: Color.fromARGB(153, 255, 255, 255))),
        //       style: ButtonStyle(
        //           overlayColor: MaterialStateProperty.resolveWith<Color>(
        //             (Set<MaterialState> states) {
        //               return Colors.transparent;
        //             },
        //           ),
        //           textStyle: const MaterialStatePropertyAll(
        //               TextStyle(color: Colors.white))),
        //     )
        //   ],
        // ),
        SizedBox(
          height: 100,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
              child: Text('     *  ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.red,
                  )),
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                '机加件号:',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
            usernameInput(username, _focusNode),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                '产品编码:',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              width: 460,
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: Text(
                resData['materialCode'] != null ? resData['materialCode'] : '-',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                '产品名称:',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              width: 460,
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: Text(
                resData['materialName'] != null ? resData['materialName'] : '-',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                '    岗位   :',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              width: 460,
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: Text(
                resData['stationCode'] != null ? resData['stationCode'] : '-',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     SizedBox(
        //       width: 50,
        //     ),
        //     Container(
        //       height: 50,
        //       margin: const EdgeInsets.only(right: 20),
        //       child: const Text(
        //         '库存状态:',
        //         style: TextStyle(
        //           color: Color(0xffC1D3FF),
        //           fontSize: 24,
        //         ),
        //       ),
        //     ),
        //     Container(
        //       width: 460,
        //       height: 50,
        //       margin: const EdgeInsets.only(right: 20),
        //       child: const Text(
        //         '1234567',
        //         style: TextStyle(
        //           color: Color(0xffC1D3FF),
        //           fontSize: 24,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                '故障原因:',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
            OutlinedButton(
                onPressed: () async {
                  selectDefect = {};
                  // print('${detailData}确认');
                  //调取不合格列表
                  if (resData['id'] != null) {
                    // await getqueryDefect();
                    showDialogFunction(context, {
                      'title': '不合格上报',
                      'width': 1050.0,
                      'content': ModalSelect(),
                      'okText': '确认',
                      'onSubmit': () {
                        print(selectDefect);
                        resData['defectCode'] = selectDefect['code'];
                        resData['defectName'] = selectDefect['name'];
                        resData['defectId'] = selectDefect['id'];
                        return true;

                        // return submitDetail(2);
                      },
                      'onCancel': () {
                        selectDefect = {};
                        setState(() {});
                      },
                    });
                  } else {
                    EasyLoading.showError('请先扫件！');
                  }
                },
                style: OutlinedButton.styleFrom(
                    fixedSize: const Size(145, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    side: const BorderSide(width: 1, color: Color(0xffb52929)),
                    // shadowColor: Color.fromARGB(135, 0, 133, 255),
                    // elevation: 5.0,
                    backgroundColor: const Color.fromARGB(40, 245, 46, 46)),
                child: const Text(
                  '选择原因',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                )),
            Container(
              width: 315,
              height: 50,
              margin: const EdgeInsets.only(left: 20),
              child: Text(
                resData['defectName'] != null ? resData['defectName'] : '-',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     SizedBox(
        //       width: 120,
        //     ),
        //     Container(
        //       // width: 460,
        //       height: 50,
        //       margin: const EdgeInsets.only(right: 20, bottom: 10),
        //       child: Checkbox(
        //           value: _isChecked,
        //           onChanged: _handleCheckboxChanged,
        //           focusColor: Colors.transparent,
        //           hoverColor: Color(0xff062969)),
        //     ),
        //     Container(
        //       width: 460,
        //       height: 50,
        //       margin: const EdgeInsets.only(right: 20),
        //       child: const Text(
        //         '是否锁定故障原因',
        //         style: TextStyle(
        //           color: Color(0xffC1D3FF),
        //           fontSize: 24,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                '检测人员:',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              width: 460,
              height: 50,
              margin: const EdgeInsets.only(right: 20),
              child: Text(
                resData['username'] != null ? resData['username'] : '-',
                style: TextStyle(
                  color: Color(0xffC1D3FF),
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                    onPressed: () {
                      print('${username.text}评审');
                      username.clear();
                      // print(dropdownMenu.currentState?.onRest);
                      // dropdownMenu.currentState?.onRest();
                      // dropdownMenu.currentState?.updateOptions([]);
                      resData = {};
                      setState(() {});
                      // showDialogFunction(
                      //   context,
                      // );
                    },
                    style: OutlinedButton.styleFrom(
                        fixedSize: const Size(180, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        side: const BorderSide(
                            width: 1, color: Color(0xff0085ff)),
                        backgroundColor: const Color.fromARGB(23, 0, 133, 255)),
                    child: const Text(
                      '重置',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700),
                    )),
                SizedBox(
                  width: 50,
                ),
                OutlinedButton(
                    onPressed: () {
                      // print('${eleSelect}${username.text}确认');
                      // if (username.text == '' || eleSelect == '') {
                      //   EasyLoading.showError('请输入必填项');
                      // } else {
                      submitDetails();
                      // }
                    },
                    style: OutlinedButton.styleFrom(
                        fixedSize: const Size(180, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        side: const BorderSide(
                            width: 1, color: Color(0xff52fefe)),
                        backgroundColor: const Color.fromARGB(20, 0, 222, 236)),
                    child: const Text(
                      '提交',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700),
                    ))
              ],
            )
          ],
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
      height: 75,
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
