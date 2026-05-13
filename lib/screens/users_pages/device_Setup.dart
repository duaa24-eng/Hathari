//باقي التشغيل رسمي \\شغاله
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
// التأكد من استيراد الملف الصحيح
import 'package:hathari_app/screens/users_pages/devuce_setup2.dart'; 

class UserDeviceSetup extends StatefulWidget {
  const UserDeviceSetup({super.key});

  @override
  State<UserDeviceSetup> createState() => _UserDeviceSetupState();
}

class _UserDeviceSetupState extends State<UserDeviceSetup> {
  // تعريف الـ Controllers
  final TextEditingController deviceNameController = TextEditingController(text: "Hathari_Device_001");
  final TextEditingController wifiNameController = TextEditingController();
  final TextEditingController wifiPasswordController = TextEditingController();
  final TextEditingController nationalAddressController = TextEditingController();

  // دالة الحفظ والانتقال لصفحة (المدينة والجوال)
  Future<void> _saveAndNext() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        // حفظ البيانات لكي تظهر في User Management عند الأدمن
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'deviceId': deviceNameController.text,
          'wifiName': wifiNameController.text,
          'wifiPassword': wifiPasswordController.text,
          'nationalAddress': nationalAddressController.text, // العنوان الوطني
        }, SetOptions(merge: true));
      }

      // الانتقال للكلاس UserDeviceSetup2 كما هو مطلوب
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserDeviceSetup2()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SingleChildScrollView(
        child: Container(
          height: 950, // طول الصفحة ليناسب جميع الحقول
          child: Stack(
            children: [
              // زر العودة
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              _buildText('Device Setup', 110, fontSize: 36, isCenter: true),

              _buildText('1. Connect to device’s Wifi:', 210, left: 24, fontSize: 18),
              _buildInputField(250, controller: deviceNameController, readOnly: true),

              _buildText('2. Write your home wifi name', 320, left: 24, fontSize: 18),
              _buildInputField(360, controller: wifiNameController),

              _buildText('3. Write your home wifi password', 430, left: 24, fontSize: 18),
              _buildInputField(470, controller: wifiPasswordController, isPassword: true),

              // مستطيل "العنوان الوطني" المتناسق باللغة الإنجليزية
              _buildText('4. National Address', 540, left: 24, fontSize: 18),
              _buildInputField(
                580,
                controller: nationalAddressController,
                isAlphaNumeric: true,
              ),

              // زر Next المائل والمتناسق
              Positioned(
                top: 780,
                left: MediaQuery.of(context).size.width / 2 - 127.72 / 2,
                child: Transform.rotate(
                  angle: 0.45 * (3.14159 / 180),
                  child: GestureDetector(
                    onTap: _saveAndNext,
                    child: Container(
                      width: 127.72,
                      height: 55.21,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E122C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Next',
                          style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء الحقول بنفس مقاسات الأرقام والمدينة (290.92 x 50.98)
  Widget _buildInputField(double top, {
    required TextEditingController controller,
    bool readOnly = false,
    bool isPassword = false,
    bool isAlphaNumeric = false
  }) {
    return Positioned(
      top: top,
      left: MediaQuery.of(context).size.width / 2 - 290.92 / 2 - 4.04,
      child: Transform.rotate(
        angle: 0.45 * (3.14159 / 180),
        child: Container(
          width: 290.92,
          height: 50.98,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            obscureText: isPassword,
            inputFormatters: isAlphaNumeric ? [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
            ] : null,
            style: TextStyle(color: readOnly ? Colors.grey : Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(String data, double top, {double? width, double? left, double fontSize = 20, bool isCenter = false}) {
    return Positioned(
      top: top,
      left: left ?? 0,
      right: left == null ? 0 : null,
      child: Container(
        width: width,
        child: Text(
          data,
          textAlign: isCenter ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: fontSize,
            color: const Color(0xFF9E122C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}