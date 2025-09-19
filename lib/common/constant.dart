import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constant {
  /// App运行在Release环境时，inProduction为true；当App运行在Debug和Profile环境时，inProduction为false
  // static const bool inProduction = kReleaseMode;
  static const String ENV = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const bool isDev =
      String.fromEnvironment('ENV', defaultValue: 'dev') == 'dev';
  // flutter build --release --dart-define=ENV=prod 生成release包
  static const String baseUrlDev =
      "https://gateway-mes-dev-v1.local.360humi.com";

  static late SharedPreferences _urlPrefs;
  static String? _hfBaseUrl;
  static String? _domainUrl;

  static String get hfBaseUrl => _hfBaseUrl ?? baseUrlDev;

  static String get domainUrl => _domainUrl ?? '';

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _urlPrefs = await SharedPreferences.getInstance();
    // if (await getBaseUrl() != null) {
      final String configString = await rootBundle.loadString(
        'assets/config.json',
      );
      final Map<String, dynamic> config = json.decode(configString);
      // 优先从SharedPreferences加载
      final String? savedHfBaseUrl = _urlPrefs.getString('hfBaseUrl');
      final String? savedDomainUrl = _urlPrefs.getString('domainUrl');

      if (savedHfBaseUrl != null && savedDomainUrl != null) {
        _hfBaseUrl = savedHfBaseUrl;
        _domainUrl = savedDomainUrl;
      } else {
        // 如果SharedPreferences中没有，则从config.json加载
        _hfBaseUrl = config['hfBaseUrl'][ENV] as String;
        _domainUrl = config['domainUrl'][ENV] as String;

        // 保存到SharedPreferences
        _urlPrefs.setString('hfBaseUrl', _hfBaseUrl!);
        _urlPrefs.setString('domainUrl', _domainUrl!);
      }
    // }
  }

  static String getDomainUrl() {
    return _urlPrefs.getString('domainUrl') ?? '';
  }

  static String getBaseUrl() {
    return _urlPrefs.getString('hfBaseUrl') ?? baseUrlDev;
  }

  // "http://10.1.200.31:8080";
  // static const String baseUrlFat = "https://privatization-gateway-fat.local.360humi.com";
  static const String baseUrlPro = "http://172.16.201.59:31817";
  static const String zdUrl = "http://apims-gw.zsdl.cn/gw"; //生产
  // static const String zdUrl = "http://190.75.16.113:8080/restcloud"; //测试
  // static const String zdUrl = "http://apims-fat.zsdl.cn/restcloud";

  static const String data = 'data';
  static const String message = 'message';
  static const String code = 'code';

  static const String accessToken = 'accessToken';
  static const String sm4key = 'sm4key';
  static const String clientId = 'clientId';
  static const String userBasicInfo = 'userBasicInfo';
  static const String userLoginInfo = 'userLoginInfo';

  static const String uuid = 'uuid';
}
