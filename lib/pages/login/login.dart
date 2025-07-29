import 'package:flutter/material.dart';
import 'package:hc_mes_app/main.dart';
import 'package:hc_mes_app/pages/home/home.dart';
import '../../common/login_prefs.dart';
import '../../common//dio_request.dart';
import 'package:hc_mes_app/utils/init.dart';
import 'package:sm_crypto/sm_crypto.dart';
import 'dart:convert';
import 'package:sp_util/sp_util.dart';
import '../../common/constant.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:auto_updater/auto_updater.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
    // 本地默认
    username.text = '17366953616';
    password.text = '1234567';
    super.initState();
    _checkAutoLogin();
  }

  void _checkAutoLogin() async {
    String? token = LoginPrefs.getToken();
    int? loginTime = LoginPrefs.getLoginTime();
    if (token != null && loginTime != null) {
      int now = DateTime.now().millisecondsSinceEpoch;
      // 30分钟 = 30 * 60 * 1000 毫秒
      if (now - loginTime < 30 * 60 * 1000) {
        // 免登录，跳转到主页面
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // 超时，清除token
        LoginPrefs.saveToken('');
        LoginPrefs.saveLoginTime(0);
      }
    }
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
    return Scaffold(
        body: Container(
      alignment: Alignment.topCenter,
      width: 1920,
      height: 1080,
      padding: const EdgeInsets.only(left: 57, right: 57),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/login-bg.png'), fit: BoxFit.cover)),
      child: Column(children: [
        Container(
            width: 1806,
            height: 108,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('images/login-title.png'),
            ))),
        Center(
          child: Container(
              width: 892,
              height: 506,
              margin: const EdgeInsets.only(top: 178),
              padding: const EdgeInsets.only(top: 50, left: 96, right: 96),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/login-form-bg.png'),
              )),
              child: Column(
                children: [
                  const Text(
                    '欢迎登录',
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
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
                                            image: AssetImage(
                                                'images/key-card.png'),
                                          ))),
                                    ),
                                  ]))),
                        ],
                      ))
                ],
              )),
        )
      ]),
    ));
  }
}

class LoginBtn extends StatefulWidget {
  final username;
  final password;
  final scancode;

  const LoginBtn({
    super.key,
    this.username,
    this.password,
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
    var response = await Request.get(
      "/mes-biz/api/mes/client/user/getBaseInfo",
    );

    if (response["success"]) {
      print('response${response}');
      var resData = response["data"] ?? {};
      var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
      finalData['employeeNo'] = resData['employeeNo'];
      finalData['employeeId'] = resData['id'];
      finalData['employeeName'] = resData['name'];
      finalData['orgId'] = resData['orgId'];

      LoginPrefs.saveUserInfo(jsonEncode(finalData));
      // LoginPrefs.saveChildUserInfo(jsonEncode(resData));
    } else {
      EasyLoading.showError(response["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return InkWell(
        onTap: () async {
          // String feedURL = 'http://10.1.200.31:18090/mes/app/version';
          // await autoUpdater.setFeedURL(feedURL);
          // await autoUpdater.checkForUpdates();
          // await autoUpdater.setScheduledCheckInterval(3600);
          var scanCode = widget.scancode.text;
          var scanusername;
          var scanpassword;
          if (scanCode.toString().contains('|')) {
            var usernamearr = scanCode.toString().split("|");
            scanusername = usernamearr[0];
            scanpassword = usernamearr[1];
          }
          //获取设备信息uuid
          var identifyUuid = await InitUtilData.identityUUID();
          var sm4Resp = await InitUtilData.getInitUuid();
          var data = json.encode({
            "clientIdentity": identifyUuid,
            "platform": 'APP',
            'username': scanusername ?? widget.username.text,
            "password": scanpassword ?? widget.password.text
          });
          final sm4Encrypt = SM4.encryptOutArray(
              data: data,
              key: sm4Resp["sm4key"],
              mode: SM4CryptoMode.ECB,
              padding: SM4PaddingMode.PKCS5);
          final result = base64.encode(sm4Encrypt);
          print(data);
          print(SpUtil.getString(Constant.sm4key));
          print(result);

          Request.post("/user-center/authentication/form", data: result)
              .then((res) async => {
                    if (res == "40114" || res == "40111")
                      {print(res)}
                    else if (res['success'])
                      {
                        print(res),
                        EasyLoading.showSuccess("登录成功"),
                        LoginPrefs.saveToken(
                            res["data"]["loginToken"]["access_token"]),
                        LoginPrefs.saveUserInfo(
                            jsonEncode(res["data"]["loginUser"])),
                        // 新增：保存当前时间戳
                        LoginPrefs.saveLoginTime(DateTime.now().millisecondsSinceEpoch),
                        await getUserInfo(),
                        userModel.setToken('123'),
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

          // widget.changeToken();
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
