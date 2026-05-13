//باقي عربي انجليزي 
import 'package:flutter/material.dart';
import 'login_user.dart';
import 'station_pages/login_station.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF), 
      body: Stack(
        children: [
          
          Positioned(
            top: 268,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Login as',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9E122C),
                ),
              ),
            ),
          ),

          
          Positioned(
            top: 361,
            left: 0,
            right: 11,
            child: Center(
              child: GestureDetector(
  onTap: () {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginUser()),
    );
  },
  child: Container(
    width: 290,
    height: 50,
    decoration: BoxDecoration(
      color: const Color(0xFF9E122C),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
      child: Text(
        'User',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    ),
  ),
),
            ),
          ),

          //firefighter bottom 
          Positioned(
            top: 454,
            left: 0,
            right: 11,
            child: Center(
              child: GestureDetector(
  onTap: () {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginStation()),
    );
  },
              child: Container(
                width: 290,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E122C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Firefighter Station',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ),
            ),
          ),  
        ],
      ),
    );
  }
}