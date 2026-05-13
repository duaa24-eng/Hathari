import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:hathari_app/screens/users_pages/fire_instuctions.dart';
import 'package:hathari_app/screens/admin_pages/guide.dart';

class InstructionsMenuScreen extends StatelessWidget {
  const InstructionsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double rotationAngle = 0.45 * (math.pi / 180);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: Stack(
          children: [
            // زر العودة
            Positioned(
              top: 20, 
              left: 20, 
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF9E122C)),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            
            _buildMenuOption(
              context: context,
              title: "Fire Instructions",
              topRectangle: (MediaQuery.of(context).size.height / 2) - 100,
              topText: (MediaQuery.of(context).size.height / 2) - 95,
              angle: rotationAngle,
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => const FireInstructionsScreen(
                      username: "Duaa24",      // تمرير يوزر الأدمن
                      password: "2003##Du",    // تمرير باسورد الأدمن
                    ),
                  ),
                );
              },
            ),

         
            _buildMenuOption(
              context: context,
              title: "App Guide",
              topRectangle: (MediaQuery.of(context).size.height / 2) + 20,
              topText: (MediaQuery.of(context).size.height / 2) + 25,
              angle: rotationAngle,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required String title,
    required double topRectangle,
    required double topText,
    required double angle,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        Positioned(
          top: topRectangle,
          left: (MediaQuery.of(context).size.width / 2) - (328.59 / 2),
          child: GestureDetector(
            onTap: onTap,
            child: Transform.rotate(
              angle: angle,
              child: Container(
                width: 328.59,
                height: 60.76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: topText,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28, // تصغير بسيط ليناسب التصميم
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E122C),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}