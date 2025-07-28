import 'package:flutter/material.dart';

class ScreenAdapter {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _ratio;

  // 设计稿基准尺寸
  static const double _designWidth = 1920;
  static const double _designHeight = 1080;

  static void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;

    // 根据宽度计算缩放比例，确保内容在不同宽度下等比例缩放
    _ratio = _screenWidth / _designWidth;
  }

  static double width(double w) {
    return w * _ratio;
  }

  static double height(double h) {
    // 对于高度，我们也可以使用相同的比例，或者根据实际需求调整
    // 如果希望高度也严格按照设计稿比例缩放，可以使用 _ratio
    // 如果希望高度在不同分辨率下保持相对一致，可能需要更复杂的逻辑
    return h * _ratio;
  }

  static double fontSize(double size) {
    return size * _ratio;
  }

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
}