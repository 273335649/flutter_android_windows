import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_windows_android_app/main.dart';
import 'package:flutter_windows_android_app/pages/positionPage/index.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart' as pdfToHtml;
import 'package:flutter/services.dart';
import '../component/global_dialog.dart';
import 'package:flutter_windows_android_app/component/web_input_positioned.dart';
import 'package:flutter_windows_android_app/common/constant.dart';
import 'package:flutter/foundation.dart';

class WebViewComponent extends StatefulWidget {
  final String initialUrl;
  final String? localStorageData;
  final String? localStorageToken;
  const WebViewComponent({
    Key? key,
    required this.initialUrl,
    this.localStorageData,
    this.localStorageToken,
  }) : super(key: key);

  @override
  State<WebViewComponent> createState() => WebViewComponentState();
}

String getWebViewUserDataFolder() {
  final home =
      Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      '.';
  return '$home/.webview2_userdata';
}

class WebViewComponentState extends State<WebViewComponent> {
  // bool _webView2Available = true;
  late InAppWebViewController _webViewController;
  late InAppWebViewController _webModalViewController;
  late TextEditingController _webInputController;
  late FocusNode _webInputFocusNode;
  late FocusNode _webModalInputFocusNode;

  BuildContext? _dialogContext;
  void reloadWebView({localStorageData}) {
    _webViewController.reload();
    // 刷新时如修改过localStorage则需要同步重新设置修改
    if (localStorageData != null) {
      _setLocalStorageInfo(_webViewController, localStorageData);
    }
  }

  @override
  void initState() {
    super.initState();
    _webInputController = TextEditingController();
    _webInputFocusNode = FocusNode();
    _webModalInputFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _webInputController.dispose();
    _webInputFocusNode.dispose();
    _webModalInputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialUrl.isEmpty) {
      return const Center(child: Text('未指定页面'));
    }
    return Stack(
      children: [
        InAppWebView(
          initialSettings: InAppWebViewSettings(
            clearCache: true,
            transparentBackground: Platform.isAndroid,
            // underPageBackgroundColor: Colors.transparent,
          ),
          initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
          onWebViewCreated: (controller) {
            _webViewController = controller;
            _setupJavaScriptHandler(controller);
            print('WebView已创建');
          },
          // 可选：监听输入框获得焦点事件
          onCreateWindow: (controller, request) {
            // 直接阻止默认弹窗行为（因为我们将用JS处理器控制）
            return Future.value(false);
          },
          onLoadStart: (controller, url) {
            print('开始加载: ${url?.toString()}');
          },
          onLoadStop: (controller, url) async {
            print('加载完成: ${url?.toString()}');
            _injectInputFocus(
              controller,
              _webInputController,
              _webInputFocusNode,
            );
            if (widget.localStorageData != null) {
              // _webviewFocusNode.requestFocus();
              _setLocalStorageInfo(controller, widget.localStorageData!);
            }
            if (widget.localStorageToken != null) {
              _setLocalStorageToken(controller, widget.localStorageToken!);
            }
          },
          onLoadError: (controller, url, code, message) {
            print('加载错误: $code - $message');
            print('URL: ${url?.toString()}');
          },
          onConsoleMessage: (controller, consoleMessage) {
            _handleConsoleMessage(consoleMessage);
          },
        ),
        WebInputPositioned(
          controller: _webInputController,
          focusNode: _webInputFocusNode,
          onChanged: (text) {
            _webViewController.evaluateJavascript(
              source:
                  "document.activeElement.value = '$text'; var event = new CustomEvent(document.activeElement.name, { detail: '$text' }); document.dispatchEvent(event);",
            );
          },
        ),
      ],
    );
  }

  // initialUrl修改时也就是切换页面了
  @override
  void didUpdateWidget(covariant WebViewComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只有controller已初始化且initialUrl有效时才loadUrl
    if (widget.initialUrl.isNotEmpty &&
        oldWidget.initialUrl != widget.initialUrl) {
      _webViewController.loadUrl(
        urlRequest: URLRequest(url: WebUri(widget.initialUrl)),
      );
      if (widget.localStorageData != null) {
        _setLocalStorageInfo(_webViewController, widget.localStorageData!);
      }
      if (widget.localStorageToken != null) {
        _setLocalStorageToken(_webViewController, widget.localStorageToken!);
      }
    }
  }

  void _injectInputFocus(
    InAppWebViewController controller,
    TextEditingController webInputController,
    FocusNode webInputFocusNode,
  ) {
    controller.addJavaScriptHandler(
      handlerName: 'webInputFocus',
      callback: (args) {
        if (args.isNotEmpty && args[0] is String) {
          webInputController.text = args[0] as String;
        }
        webInputFocusNode.requestFocus();
      },
    );

    controller.evaluateJavascript(
      source: """
              function activeElementChange(event){
                // 在触摸事件中，尝试将焦点设置到当前活动的元素（如果有的话）或者body
                // 这里可以根据需要调整，例如只对input元素进行聚焦
                // 检查当前是否有活动元素，并且该元素是输入框或文本区域
                function setFocus(){
                  document.activeElement.setAttribute('data-focus_flutter', 'true');
                  if (document.activeElement?.parentElement) {
                    document.activeElement.parentElement?.setAttribute('data-focus_flutter', 'true');
                  }
                  window.flutter_inappwebview.callHandler('webInputFocus', document.activeElement.value);
                }
                // 移除所有之前设置的 data-focus_flutter="true" 属性
                document.querySelectorAll('[data-focus_flutter="true"]').forEach(el => {
                  el.removeAttribute('data-focus_flutter');
                });
                if (document.activeElement && (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA') && document.activeElement.classList.contains('ant-input')) {
                  setFocus();
                } else if ((event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') && event.target.classList.contains('ant-input')) {
                  // 如果触摸目标是输入框或文本区域，则对其进行聚焦
                  setFocus();
                } else {
                  // 否则，强制聚焦到body
                  // document.body.focus();
                }
              }
              document.addEventListener('click', function(event) {
                activeElementChange(event);
              });
              document.addEventListener('touchstart', function(event) {
                activeElementChange(event);
              });
            """,
    );
  }

  void _handleConsoleMessage(ConsoleMessage consoleMessage) {
    // 处理控制台消息，可以用于调试
    print('WebView Console: ${consoleMessage.message}');
  }

  void _setLocalStorageInfo(
    InAppWebViewController controller,
    String data,
  ) async {
    final String script = "localStorage.setItem('loginInfo', '$data');";
    // String? token = LoginPrefs.getToken();
    await controller.evaluateJavascript(source: script);
    print('Login info set in localStorage: $data');
  }

  void _setLocalStorageToken(
    InAppWebViewController controller,
    String data,
  ) async {
    final String script = "localStorage.setItem('token', '$data');";
    // String? token = LoginPrefs.getToken();
    await controller.evaluateJavascript(source: script);
    print('Login info set in localStorage: $data');
  }

  // 网页js调用
  void _setupJavaScriptHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'openFullscreenPopup',
      callback: (args) {
        _handleOpenFullscreenPopup(args);
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'openIndexModal',
      callback: (args) async {
        final result = await _handleOpenIndexModal(args);
        return result; // 返回数据给H5的then方法
      },
    );
  }

  // 弹窗网页js调用
  void _setupModalJavaScriptHandler(InAppWebViewController controller) {
    // _setupInputJavaScriptHandler(controller);
    controller.addJavaScriptHandler(
      handlerName: 'closeFullscreenPopup',
      callback: (args) {
        if (_dialogContext != null && Navigator.of(_dialogContext!).canPop()) {
          Navigator.of(_dialogContext!).pop();
          _dialogContext = null; // 弹窗关闭时置为null
        }
        if (args.isNotEmpty) {
          // 传递给主WebView
          _webViewController.evaluateJavascript(
            source: "window.onPopupClosed(${jsonEncode(args)});",
          );
        }
        return jsonEncode(args);
      },
    );
  }

  Future<dynamic> _handleOpenIndexModal(List<dynamic> args) async {
    final String index = args[0] as String;
    dynamic result;
    if (index == "positionPage") {
      // 岗位选择
      result = await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            child: PositionPage(
              onConfirm: (data) async {
                // Close the dialog after confirmation and pass data back
                Navigator.of(dialogContext).pop(data);
              },
            ),
          );
        },
      );
      return result; // 返回弹窗关闭时传递的数据
    }
    return null; // 如果没有打开弹窗，返回null
  }

  // 弹窗打开时，弹窗内容
  // TODO优化建议：如果弹窗频繁打开且内容相同，可以考虑将 `InAppWebView` 实例提升到父组件的状态中，并在弹窗关闭时不销毁，而是隐藏，下次打开时直接显示已存在的实例
  void _handleOpenFullscreenPopup(List<dynamic> args) {
    final String url = args[0] as String;
    if (url.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          _dialogContext =
              dialogContext; // Assign dialogContext to _dialogContext
          return Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                InAppWebView(
                  initialSettings: InAppWebViewSettings(
                    transparentBackground: Platform.isAndroid,
                    // underPageBackgroundColor: Colors.transparent,
                  ),
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  onWebViewCreated: (controller) {
                    _webModalViewController = controller;
                    _setupModalJavaScriptHandler(controller);
                  },
                  onLoadStop: (controller, url) async {
                    print('加载完成: ${url?.toString()}');
                    _injectInputFocus(
                      controller,
                      _webInputController,
                      _webModalInputFocusNode,
                    );
                    if (widget.localStorageData != null) {
                      _setLocalStorageInfo(
                        controller,
                        widget.localStorageData!,
                      );
                    }
                    if (widget.localStorageToken != null) {
                      _setLocalStorageToken(
                        controller,
                        widget.localStorageToken!,
                      );
                    }
                  },
                ),
                WebInputPositioned(
                  controller: _webInputController,
                  focusNode: _webModalInputFocusNode,
                  onChanged: (text) {
                    _webModalViewController.evaluateJavascript(
                      source:
                          "document.activeElement.value = '$text'; var event = new CustomEvent(document.activeElement.name, { detail: '$text' }); document.dispatchEvent(event);",
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
