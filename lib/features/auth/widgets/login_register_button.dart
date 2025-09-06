import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginRegisterButton extends StatelessWidget {
  const LoginRegisterButton({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      alignment: Alignment.centerRight,
      onPressed: () {
        context.pushNamed('register');
      },
      child: const Text(
        'Đăng ký',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
