//doonneeeee
import 'package:flutter/material.dart';
import 'dart:async';

class LogoPage extends StatefulWidget {
  @override
  _LogoPageState createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: Center(
        child: Container(
          width: 700, 
          height: 700,
         
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('photos/logo.png'), 
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}