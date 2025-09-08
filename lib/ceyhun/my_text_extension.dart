import 'package:flutter/material.dart';

extension StringTextExtension on String {
  _TextBuilder get text => _TextBuilder(this);
}

class _TextBuilder {
  final String data;
  TextAlign? _align;
  FontWeight? _fontWeight;
  FontStyle? _fontStyle;
  double? _fontSize;
  Color? _color;
  TextDecoration? _decoration;
  bool _uppercase = false;
  bool _capitalize = false;
  double? _letterSpacing;

  _TextBuilder(this.data);

  _TextBuilder get bold {
    _fontWeight = FontWeight.bold;
    return this;
  }

  _TextBuilder get italic {
    _fontStyle = FontStyle.italic;
    return this;
  }

  _TextBuilder get underline {
    _decoration = TextDecoration.underline;
    return this;
  }

  _TextBuilder get uppercase {
    _uppercase = true;
    return this;
  }

  _TextBuilder get capitalize {
    _capitalize = true;
    return this;
  }

  _TextBuilder size(double size) {
    _fontSize = size;
    return this;
  }

  _TextBuilder spacing(double value) {
    _letterSpacing = value;
    return this;
  }

  _TextBuilder align(TextAlign align) {
    _align = align;
    return this;
  }

  _TextBuilder color(Color color) {
    _color = color;
    return this;
  }

  _TextBuilder get red => color(Colors.red);
  _TextBuilder get blue => color(Colors.blue);
  _TextBuilder get green => color(Colors.green);
  _TextBuilder get yellow => color(Colors.yellow);
  _TextBuilder get orange => color(Colors.orange);
  _TextBuilder get pink => color(Colors.pink);
  _TextBuilder get purple => color(Colors.purple);
  _TextBuilder get black => color(Colors.black);
  _TextBuilder get white => color(Colors.white);
  _TextBuilder get grey => color(Colors.grey);
  _TextBuilder get blueGrey => color(Colors.blueGrey);
  _TextBuilder get greenAccent => color(Colors.greenAccent);
  _TextBuilder get blue500 => color(Colors.blue.shade500);
  _TextBuilder get grey700 => color(Colors.grey.shade700);

  Text make() {
    String finalData = data;
    if (_uppercase) finalData = finalData.toUpperCase();
    if (_capitalize && finalData.isNotEmpty) {
      finalData = finalData[0].toUpperCase() + finalData.substring(1);
    }
    return Text(
      finalData,
      textAlign: _align,
      style: TextStyle(
        fontWeight: _fontWeight,
        fontStyle: _fontStyle,
        fontSize: _fontSize,
        color: _color,
        decoration: _decoration,
        letterSpacing: _letterSpacing,
      ),
    );
  }

  Widget makeCentered() => Center(child: make());
  Widget padded([EdgeInsets padding = const EdgeInsets.all(8)]) =>
      Padding(padding: padding, child: make());
}
