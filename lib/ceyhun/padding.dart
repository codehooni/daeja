import 'package:flutter/widgets.dart';

extension PaddingExtension on Widget {
  /// 개별 방향에 대해 설정: left, right, top, bottom
  Widget p({double l = 0, double r = 0, double t = 0, double b = 0}) => Padding(
    padding: EdgeInsets.only(left: l, right: r, top: t, bottom: b),
    child: this,
  );

  /// 수평(h), 수직(v) padding을 지정할 수 있음
  Widget pSymmetric({double h = 0, double v = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
    child: this,
  );

  /// 전체 동일 padding
  Widget pAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// 수평 전용
  Widget pH(double value) => Padding(
    padding: EdgeInsets.symmetric(horizontal: value),
    child: this,
  );

  /// 수직 전용
  Widget pV(double value) => Padding(
    padding: EdgeInsets.symmetric(vertical: value),
    child: this,
  );
}
