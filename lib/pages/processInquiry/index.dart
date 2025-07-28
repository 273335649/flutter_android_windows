import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../common//dio_request.dart';

import 'package:hc_mes_app/common/login_prefs.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:webview_windows/webview_windows.dart';
import 'package:hc_mes_app/utils/init.dart';

import '../../common/constant.dart';

class ProcessInquiry extends StatefulWidget {
  const ProcessInquiry({super.key});

  @override
  State<ProcessInquiry> createState() => _ProcessInquiryState();
}

class _ProcessInquiryState extends State<ProcessInquiry> {
  int activeIndex = 0;
  double scale = 1;
  // void setScale(double scale) {
  //   // 获取当前的transformationController
  //   final controller = widget.transformationController;
  //   // 使用Matrix4来创建一个新的变换矩阵
  //   final newMatrix = Matrix4.identity()..scale3D(scale, scale, 1.0); // 设置缩放倍数
  //   // 应用新的变换矩阵
  //   controller.value = newMatrix;
  // }

  @override
  Widget build(BuildContext context) {
    print(activeIndex);
    return Container(
        width: 1340,
        height: 780,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            activeIndex = 0;
                            scale = 1;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                            fixedSize: const Size(180, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            side: const BorderSide(
                                width: 1, color: Color(0xff0085ff)),
                            backgroundColor: activeIndex == 1
                                ? Colors.transparent
                                : Color.fromARGB(112, 0, 94, 236)),
                        child: const Text(
                          '图纸',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700),
                        )),
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            activeIndex = 1;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                            fixedSize: const Size(180, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            side: const BorderSide(
                                width: 1, color: Color(0xff0085ff)),
                            backgroundColor: activeIndex == 0
                                ? Colors.transparent
                                : Color.fromARGB(112, 0, 94, 236)),
                        child: const Text(
                          '视频',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700),
                        )),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                        color: Colors.white,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent, // 透明色
                        splashColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            if (scale == 1.0) {
                              scale = double.parse('1.0');
                            } else {
                              scale = double.parse(
                                  (scale - 0.1).toStringAsFixed(1));
                            }
                          });
                        },
                        icon: Icon(Icons.zoom_out_outlined)),
                    Slider(
                      value: scale,
                      max: 2.0,
                      min: 1.0,
                      onChanged: (value) {
                        // 拖动改变进度

                        setState(() {
                          scale = value;
                        });
                      },
                    ),
                    IconButton(
                        color: Colors.white,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent, // 透明色
                        splashColor: Colors.transparent,
                        onPressed: () {
                          print(scale.toStringAsFixed(1));
                          setState(() {
                            if (scale.toStringAsFixed(1) == '2.0') {
                              scale = double.parse('2.0');
                            } else {
                              scale = double.parse(
                                  (scale + 0.1).toStringAsFixed(1));
                            }
                          });
                        },
                        icon: Icon(Icons.zoom_in_outlined)),
                  ],
                )
              ],
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                SizedBox(
                  width: 8,
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                        // clipBehavior: Clip.hardEdge,
                        // decoration: BoxDecoration(),
                        // width: 500,
                        height: 670,
                        child: activeIndex == 0
                            ?
                            // Transform.scale(
                            //     scale: 1,
                            //     child: MyPhotoView(),
                            //   )
                            InteractiveViewer(
                                scaleEnabled: false,
                                transformationController:
                                    TransformationController(Matrix4.identity()
                                      ..scale(scale, scale, 1.0)),
                                child: MyPhotoView())
                            : MyVideo()))
              ],
            )
          ],
        ));
  }
}

class MyPhotoView extends StatefulWidget {
  const MyPhotoView({super.key});

  @override
  State<MyPhotoView> createState() => _MyPhotoViewState();
}

class _MyPhotoViewState extends State<MyPhotoView> {
  late WebviewController _controller;
  //登录鉴权
  Future zdLogin() async {
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
      return response["identitytoken"];
    } else {
      EasyLoading.showError(response["message"]);
      return '';
    }
  }

  Future<void> getTableData(exts) async {
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    var materialInfoData = jsonDecode(LoginPrefs.getMaterialInfo() ?? '{}');
    print('物料信息：${materialInfoData}');
    print(finalData['lineCode']);
    if (materialInfoData['materialId'] == null) {
      print('没有物料信息');
      EasyLoading.showError('请先扫描产品件号');
    } else {
      var params = {
        'exts': exts,
        'employeeId': finalData['employeeId'],
        'employeeNo': finalData['employeeNo'],
        'employeeName': finalData['employeeName'],
        'lineCode': finalData['lineCode'],
        'lineName': finalData['lineName'],
        'lineId': finalData['lineId'],
        'materialId': materialInfoData['materialId'],
        'materialCode': materialInfoData['materialCode'],
        'materialName': materialInfoData['materialName'],
      };
      print('工艺sop请求参数：${params}');
      var response = await Request.post(
          "/mes-biz/api/mes/client/task/querySopByExtAndMaterialId",
          data: params);
      if (response["success"]) {
        var resData = response ?? [];

        print('查看接口数据 ${resData}');
        if (resData['data']?.length > 0) {
          getUrl(resData['data'][0]);
        }
        setState(() {});
      } else {
        EasyLoading.showError('${response['message']}');
      }
    }
  }

  Future<void> getUrl(fileName) async {
    var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // String clientToken = await zdLogin();
    // print('clientId：${clientToken}');
    print(infoData);
    Map<String, dynamic> jsonMap = jsonDecode(fileName);
    var _fileName = jsonMap.keys.first;
    var params = {"urlType": "getFile", "fileName": _fileName};
    print('接口提交信息${params}');

    var response = await Request.get("/mes-admin/meta/column/getUploadInfo",
        params: params);
    print('接口返回数据：${response}');
    await _controller.setBackgroundColor(Colors.white);
    await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    await _controller.loadUrl("${response['data']}");
    // await _controller.loadUrl(
    //     "https://obsak.langyagplat.com/help_doc/19%20%E5%AE%89%E5%BE%BD%E5%BA%B7%E4%BD%B3%E5%B7%A5%E4%B8%9A%E4%BA%92%E8%81%94%E7%BD%91%E5%B9%B3%E5%8F%B0%E4%BC%81%E4%B8%9A%E8%AE%A4%E8%AF%81%E6%93%8D%E4%BD%9C%E6%89%8B%E5%86%8C.pdf");

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    // await WebviewController.initializeEnvironment(
    //     additionalArguments: '--show-fps-counter');
    try {
      await _controller.initialize();
      await getTableData(['.pdf']);

      if (!mounted) return;
      setState(() {});
    } catch (e) {}
  }

  @override
  void initState() {
    _controller = WebviewController();
    initPlatformState();

    super.initState();

    // 如果需要，你可以在这里进行异步操作，但要确保在 _controller 使用前完成
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // InteractiveViewer(
        //     boundaryMargin: EdgeInsets.all(999999),
        //     child: Container(
        //       height: 670,
        //       child: Webview(_controller),
        //     ))

        Expanded(
          flex: 1,
          child: Webview(_controller),
        )
      ],
    );

    //   ],
    // );
  }

  @override
  void deactivate() {
    _controller.dispose();
    super.deactivate();
  }
}

class MyVideo extends StatefulWidget {
  const MyVideo({super.key});

  @override
  State<MyVideo> createState() => _MyVideoState();
}

class _MyVideoState extends State<MyVideo> {
  // late WinVideoPlayerController controller;
  bool hasData = false;
  late final player = Player();
  late final controller = VideoController(player);

  //登录鉴权
  Future zdLogin() async {
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
      return response["identitytoken"];
    } else {
      EasyLoading.showError(response["message"]);
      return '';
    }
  }

  Future<void> getTableData(exts) async {
    var finalData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    var materialInfoData = jsonDecode(LoginPrefs.getMaterialInfo() ?? '{}');
    print('物料信息：${materialInfoData}');
    // print(finalData['lineCode']);

    if (materialInfoData['materialId'] == null) {
      print('没有物料信息');
      EasyLoading.showError('请先扫描产品件号');
    } else {
      var params = {
        'exts': exts,
        'employeeId': finalData['employeeId'],
        'employeeNo': finalData['employeeNo'],
        'employeeName': finalData['employeeName'],
        'lineCode': finalData['lineCode'],
        'lineName': finalData['lineName'],
        'lineId': finalData['lineId'],
        'materialId': materialInfoData['materialId'],
        'materialCode': materialInfoData['materialCode'],
        'materialName': materialInfoData['materialName'],
      };
      print('工艺sop请求参数：${params}');
      var response = await Request.post(
          "/mes-biz/api/mes/client/task/querySopByExtAndMaterialId",
          data: params);

      print('工艺sop返回数据 ${response}');
      if (response["success"]) {
        var resData = response ?? [];
        print('查看接口数据 ${resData}');
        if (resData['data']?.length > 0) {
          print('查看接口数据 ${resData['data'][0]}');
          getUrl(resData['data'][0]);
        }
        setState(() {});
      } else {
        EasyLoading.showError('${response['message']}');
      }
    }
  }

  Future<void> getUrl(fileName) async {
    // var infoData = jsonDecode(LoginPrefs.getUserInfo() ?? '');
    // String clientToken = await zdLogin();
    // print('clientId：${clientToken}');
    // print(infoData);
    Map<String, dynamic> jsonMap = jsonDecode(fileName);
    var _fileName = jsonMap.keys.first;
    var params = {"urlType": "getFile", "fileName": _fileName};
    print('接口提交信息${fileName}');

    var response = await Request.get("/mes-admin/meta/column/getUploadInfo",
        params: params);
    print('接口返回数据：${response}');
    hasData = true;
    player.open(Media("${response['data']}"));

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getTableData(['.avi', '.mp4']);
    // controller = WinVideoPlayerController();
    // reload();
  }

  @override
  void deactivate() {
    super.deactivate();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: hasData == true
            ? SizedBox(
                // height: 500,
                child: Video(
                  controller: controller,
                  controls: MaterialVideoControls,
                ),
              )
            : null);
  }
}
