//done 23\4
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:hathari_app/screens/login_user.dart'; // تأكد من المسار الصحيح لصفحة اللوجن
import 'package:hathari_app/screens/admin_pages/station_manage.dart';
import 'package:hathari_app/screens/admin_pages/inst.dart';
import 'package:hathari_app/screens/admin_pages/devicemange.dart';
import 'package:hathari_app/screens/admin_pages/userMange.dart';
import 'package:hathari_app/screens/admin_pages/alertMang.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) {
  
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginUser()),
      (route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    const double designWidth = 393.0;
    const double designHeight = 852.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: Center(
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: Stack(
            children: [
              
              const Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9E122C),
                    ),
                  ),
                ),
              ),

            
              _buildSettingButton(
                text: "Alert Management",
                topRect: 220,
                topText: 232,
                textWidth: 260,
                leftOffset: 0,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AlertManagementScreen())),
              ),

              _buildSettingButton(
                text: "User Management",
                topRect: 310,
                topText: 322,
                textWidth: 260,
                leftOffset: 0,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserManagement())),
              ),

              _buildSettingButton(
                text: "Station Management",
                topRect: 400,
                topText: 412,
                textWidth: 280,
                leftOffset: 0,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StationManagement())),
              ),

              _buildSettingButton(
                text: "Device Management",
                topRect: 490,
                topText: 502,
                textWidth: 280,
                leftOffset: 0,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeviceManagement())),
              ),

              _buildSettingButton(
                text: "Instructions ",
                topRect: 580,
                topText: 592,
                textWidth: 280,
                leftOffset: 0,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InstructionsMenuScreen())),
              ),

              // --- زر تسجيل الخروج (Log Out) ---
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // الخط الأحمر تحت الزر
                    Container(
                      width: 150,
                      height: 2,
                      color: const Color(0xFF9E122C),
                    ),
                    TextButton(
                      onPressed: () => _logout(context),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9E122C),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- زر الرجوع العلوي ---
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingButton({
    required String text,
    required double topRect,
    required double topText,
    required double textWidth,
    required double leftOffset,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        Positioned(
          top: topRect,
          left: (393 / 2) - (328.59 / 2),
          child: Transform.rotate(
            angle: 0.45 * (math.pi / 180),
            child: Container(
              width: 328.59,
              height: 60.76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: topText,
          left: (393 / 2) - (textWidth / 2) + leftOffset,
          child: IgnorePointer(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E122C),
              ),
            ),
          ),
        ),
        Positioned(
          top: topRect,
          left: (393 / 2) - (328.59 / 2),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 328.59,
              height: 60.76,
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}