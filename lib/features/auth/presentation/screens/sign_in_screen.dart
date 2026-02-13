import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: '로그인'.text.make()),
    );
  }
}
