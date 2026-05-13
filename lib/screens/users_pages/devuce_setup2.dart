//باقي التشغيل رسمي\\شغاله
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class UserDeviceSetup2 extends StatefulWidget {
  const UserDeviceSetup2({super.key});

  @override
  State<UserDeviceSetup2> createState() => _UserDeviceSetup2State();
}

class _UserDeviceSetup2State extends State<UserDeviceSetup2> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nationalAddressController = TextEditingController();
  
  // متغير لحفظ المدينة المختارة من القائمة
  String? selectedCity;

  // قائمة مدن السعودية
  final List<String> saudiCities = [
    'Riyadh', 'Jeddah', 'Dammam', 'Makkah', 'Madinah', 
    'Abha', 'Tabuk', 'Hail', 'Jazan', 'Najran', 'Al-Khobar'
  ];

  // دالة الحفظ النهائي والربط مع صفحة الواي فاي
  Future<void> _handleSave() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'phoneNumber': phoneController.text,
          'city': selectedCity, // حفظ المدينة المختارة
          'nationalAddress': nationalAddressController.text,
        }, SetOptions(merge: true)); // دمج البيانات مع الصفحة الأولى
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Success: All data saved!")),
      );

      // العودة للرئيسية
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF), // نفس خلفية الصفحة الأولى
      body: SingleChildScrollView(
        child: Container(
          height: 852, 
          child: Stack(
            children: [
              // زر الرجوع
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              _buildText('Complete Setup', 130, fontSize: 36, isCenter: true),

              // 1. رقم الجوال
              _buildText('5. Phone Number', 250, left: 24),
              _buildInputField(290, controller: phoneController, isNumber: true, hint: "05xxxxxxxx"),

              // 2. قائمة المدن المنسدلة (Dropdown)
              _buildText('6. Select City', 370, left: 24),
              _buildDropdownField(410),

              // 3. العنوان الوطني
              _buildText('7. National Address', 490, left: 24),
              _buildInputField(530, controller: nationalAddressController, hint: "Example: 1234 AB"),

              // زر Save المائل المتناسق
              Positioned(
                bottom: 120,
                left: MediaQuery.of(context).size.width / 2 - 127.72 / 2,
                child: Transform.rotate(
                  angle: 0.45 * (3.14159 / 180),
                  child: GestureDetector(
                    onTap: _handleSave,
                    child: Container(
                      width: 140,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E122C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
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

  // دالة بناء القائمة المنسدلة للمدن بنفس التصميم المائل
  Widget _buildDropdownField(double top) {
    return Positioned(
      top: top,
      left: MediaQuery.of(context).size.width / 2 - 290.92 / 2 - 4.04,
      child: Transform.rotate(
        angle: 0.45 * (3.14159 / 180),
        child: Container(
          width: 290.92,
          height: 50.98,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCity,
              hint: const Text("Select your city", style: TextStyle(fontSize: 14)),
              isExpanded: true,
              items: saudiCities.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCity = newValue;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  // دالة بناء الحقول النصية (نفس مقاسات الصفحة الأولى)
  Widget _buildInputField(double top, {required TextEditingController controller, String hint = "", bool isNumber = false}) {
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
            keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
            inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(String data, double top, {double? left, double fontSize = 20, bool isCenter = false}) {
    return Positioned(
      top: top,
      left: left ?? 0,
      right: left == null ? 0 : null,
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
    );
  }
}