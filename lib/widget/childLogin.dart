import 'package:flutter/material.dart';
import '../common/login_prefs.dart';

import 'package:hc_mes_app/main.dart';
import 'package:hc_mes_app/pages/home/home.dart';

import '../../common//dio_request.dart';
import 'package:hc_mes_app/utils/init.dart';
import 'package:sm_crypto/sm_crypto.dart';
import 'dart:convert';
import 'package:sp_util/sp_util.dart';
import '../../common/constant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import '../pages/Login/Login.dart';

class ChildLogin extends StatefulWidget {
  const ChildLogin({super.key, this.title});

  final title;

  @override
  State<ChildLogin> createState() => _ChildLoginState();
}

class _ChildLoginState extends State<ChildLogin> {
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController scancode = TextEditingController();
  FocusNode usernamefocusNode = FocusNode();
  FocusNode passwordfocusNode = FocusNode();
  FocusNode scancodefocusNode = FocusNode();
  var selectedInput;
  var selectedInputNode;
  @override
  void initState() {
    // TODO: implement initState
    usernamefocusNode.addListener(_handleFocusChanged);
    passwordfocusNode.addListener(_handleFocusChanged);
    scancodefocusNode.addListener(_handleFocusChanged);
    super.initState();
  }

  @override
  void dispose() {
    usernamefocusNode.removeListener(_handleFocusChanged);
    passwordfocusNode.removeListener(_handleFocusChanged);
    scancodefocusNode.removeListener(_handleFocusChanged);
    usernamefocusNode.dispose();
    passwordfocusNode.dispose();
    scancodefocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (usernamefocusNode.hasFocus) {
      selectedInput = username;
      selectedInputNode = usernamefocusNode;
    }
    if (passwordfocusNode.hasFocus) {
      selectedInput = password;
      selectedInputNode = passwordfocusNode;
    }
    if (scancodefocusNode.hasFocus) {
      selectedInput = scancode;
      selectedInputNode = scancodefocusNode;
    }
  }

  void handleKey(value) {
    if (selectedInput != null) {
      var newvalue = selectedInput.text + value;

      selectedInput.value = selectedInput.value.copyWith(
          text: newvalue,
          selection: TextSelection.fromPosition(TextPosition(
              affinity: TextAffinity.downstream, offset: newvalue.length)));
      FocusScope.of(context).requestFocus(selectedInputNode);
    }
  }

  void delKey() {
    if (selectedInput != null && selectedInput.text != '') {
      var newvalue =
          selectedInput.text.substring(0, selectedInput.text.length - 1);

      selectedInput.value = selectedInput.value.copyWith(
          text: newvalue,
          selection: TextSelection.fromPosition(TextPosition(
              affinity: TextAffinity.downstream, offset: newvalue.length)));
      FocusScope.of(context).requestFocus(selectedInputNode);
    }
  }

  void clearKey() {
    if (selectedInput != null) {
      selectedInput.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 1336,
      height: 777,
      padding: const EdgeInsets.only(
        left: 57,
        right: 57,
      ),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/child-login-bg.png'),
              fit: BoxFit.cover)),
      child: Column(children: [
        Container(
            width: 892,
            height: 505,
            margin: const EdgeInsets.only(top: 100),
            padding: const EdgeInsets.only(top: 50, left: 96, right: 96),

            // margin: const EdgeInsets.only(top: 20),
            // padding: const EdgeInsets.only(top: 50),
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('images/login-form-bg.png'),
            )),
            child: Column(
              children: [
                Text(
                  '${widget.title}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Color(0xffC1D3FF)),
                ),
                Form(
                  key: form,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 40,
                                ),
                                usernameInput(username, usernamefocusNode),
                                const SizedBox(
                                  height: 24,
                                ),
                                passwordInput(password, passwordfocusNode),
                                const SizedBox(
                                  height: 24,
                                ),
                                scancodeInput(scancode, scancodefocusNode),
                                const SizedBox(
                                  height: 24,
                                ),
                                SizedBox(
                                  width: 379,
                                  height: 79,
                                  child: LoginBtn(
                                      username: username,
                                      password: password,
                                      scancode: scancode),
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 1,
                          child: Container(
                              // alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 10),
                              padding: EdgeInsets.only(top: 30),
                              child: Wrap(children: [
                                InkWell(
                                  onTap: () {
                                    handleKey('7');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '7',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('8');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '8',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('9');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '9',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('4');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '4',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('5');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '5',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('6');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '6',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('1');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '1',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('2');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '2',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('3');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '3',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    handleKey('0');
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '0',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    delKey();
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '删除',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    clearKey();
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: 108,
                                      height: 76,
                                      child: Text(
                                        '清空',
                                        style: TextStyle(
                                            color: Color(0xFFC1D3FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/key-card.png'),
                                      ))),
                                ),
                              ]))),
                    ],
                  ),
                )
              ],
            )),
      ]),
    );
  }
}

class LoginBtn extends StatefulWidget {
  final username;
  final password;
  final changeToken;
  final scancode;
  const LoginBtn({
    super.key,
    this.username,
    this.password,
    this.changeToken,
    this.scancode,
  });
  // const LoginBtn({super.key});

  @override
  State<LoginBtn> createState() => _LoginBtnState();
}

class _LoginBtnState extends State<LoginBtn> {
  var loginBtnImg = 'images/login-btn.png';

  //获取用户详情
  Future<void> getUserInfo() async {
    var response = await Request.get("/mes-biz/api/mes/client/user/getBaseInfo",
        isChildToken: true);
    if (response["success"]) {
      var resData = response["data"] ?? {};
      print('子用户信息：${jsonEncode(resData)}');
      var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
      LoginPrefs.saveChildUserInfo(jsonEncode(resData));
      await Request.post("/mes-biz/api/operationLog/save", data: {
        "description": '子用户:${resData['name']}登录成功',
        "lineId": finalData['lineId'],
        "lineName": finalData['lineName'],
        "stationId": finalData['stationId'],
        "stationName": finalData['stationName'],
        "title": '子用户登录成功',
      });
    } else {
      EasyLoading.showError(response["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return InkWell(
        onTap: () async {
          var scanCode = widget.scancode.text;
          var scanusername;
          var scanpassword;
          if (scanCode.toString().contains('|')) {
            var usernamearr = scanCode.toString().split("|");
            scanusername = usernamearr[0];
            scanpassword = usernamearr[1];
          }
          var identifyUuid = LoginPrefs.getclientId();
          var sm4Resp = LoginPrefs.getSm4key();
          var data = json.encode({
            "clientIdentity": identifyUuid,
            "platform": 'APP',
            'username': scanusername ?? widget.username.text,
            "password": scanpassword ?? widget.password.text
          });
          print(sm4Resp);
          final sm4Encrypt = SM4.encryptOutArray(
              data: data,
              key: sm4Resp ?? '',
              mode: SM4CryptoMode.ECB,
              padding: SM4PaddingMode.PKCS5);
          final result = base64.encode(sm4Encrypt);

          Request.post("/user-center/authentication/form",
              data: result, isChildToken: true, onBadResponse: () {
            userModel.clear();
          }).then((res) async => {
                if (res['success'])
                  {
                    print(res["data"]),
                    EasyLoading.showSuccess("登录成功"),
                    LoginPrefs.saveChildToken(
                        res["data"]["loginToken"]["access_token"]),
                    await getUserInfo(),
                    userModel.setChildInfo(
                        {'name': res["data"]["loginUser"]['username']}),
                    userModel.setChildToken('123'),
                    // LoginPrefs.saveChildUserInfo(
                    //     jsonEncode(res["data"]["loginUser"])),
                    // widget.changeToken(),
                  }
                else
                  {
                    print(res['message']),
                    EasyLoading.showError("登录失败:${res["message"]}")
                  }
                // if (res['success'] == true)
                //   {
                //     print('登录请求，${res}'),
                //     //   LoginPrefs.saveToken(res['data']['token']);
                //     // myStatefulWidgetKey.currentState?.changeToken()
                //     // widget.changeToken(),
                //     userModel.setToken('123'),
                //   }
              });
          print('${widget.username.text}子登录成功');
        },
        onHover: (value) {
          setState(() {
            loginBtnImg =
                value ? 'images/login-btn-hover.png' : "images/login-btn.png";
          });
        },
        child: Image(image: AssetImage(loginBtnImg), fit: BoxFit.fill));
  }
}

OutlineInputBorder _outlineInputBorder = OutlineInputBorder(
  gapPadding: 0,
  borderSide: BorderSide(
    color: Color(0xff4b74dc),
  ),
);

Widget usernameInput(TextEditingController username, focusNode) {
  return TextFormField(
    controller: username,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      prefixIcon: Image(
        image: AssetImage('images/username-icon.png'),
      ),
      hintText: '用户名',
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
    focusNode: focusNode,
    onSaved: (v) => username.text = v!,
  );
}

Widget passwordInput(TextEditingController password, focusNode) {
  return TextFormField(
    obscureText: true,
    controller: password,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      prefixIcon: Image(
        image: AssetImage('images/password-icon.png'),
      ),
      hintText: '密码',
      hintStyle: TextStyle(color: Color(0xffC1D3FF)),
      border: _outlineInputBorder,
      focusedBorder: _outlineInputBorder,
      enabledBorder: _outlineInputBorder,
      disabledBorder: _outlineInputBorder,
      focusedErrorBorder: _outlineInputBorder,
      errorBorder: _outlineInputBorder,
    ),
    focusNode: focusNode,
    // onSaved: (v) => _email = v!,
  );
}

Widget scancodeInput(TextEditingController password, focusNode) {
  return TextFormField(
    obscureText: true,
    controller: password,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      prefixIcon: Image(
        image: AssetImage('images/password-icon.png'),
      ),
      hintText: '请点击扫码',
      hintStyle: TextStyle(color: Color(0xffC1D3FF)),
      border: _outlineInputBorder,
      focusedBorder: _outlineInputBorder,
      enabledBorder: _outlineInputBorder,
      disabledBorder: _outlineInputBorder,
      focusedErrorBorder: _outlineInputBorder,
      errorBorder: _outlineInputBorder,
    ),

    // onSaved: (v) => _email = v!,
    focusNode: focusNode,
  );
}
