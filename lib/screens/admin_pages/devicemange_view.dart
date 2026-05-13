import 'package:flutter/material.dart';
import 'dart:math' as math;

class DeviceManageView extends StatelessWidget {
  final String deviceId;
  final Map<String, dynamic> deviceData;

  const DeviceManageView({
    super.key,
    required this.deviceId,
    required this.deviceData,
  });

  @override
  Widget build(BuildContext context) {
    // تدوير خفيف جداً ليتناسب مع ستايل التصميم السابق
    final double rotationAngle = 0.5 * (math.pi / 180);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        // إزالة التمرير إذا لم يكن ضرورياً لتبقى في صفحة واحدة
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              // --- سهم العودة ---
              Positioned(
                top: 20, 
                left: 0, 
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // --- العنوان ---
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Device Details',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9E122C),
                    ),
                  ),
                ),
              ),

              // --- منطقة البيانات (تم رفعها قليلاً لتناسب الصفحة الواحدة) ---
              Positioned(
                top: 160,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    _buildDataRow("Device ID:", deviceData['deviceId']?.toString() ?? 'N/A', rotationAngle),
                    const SizedBox(height: 18),
                    _buildDataRow("User Name:", deviceData['userName']?.toString() ?? 'Unknown', rotationAngle),
                    const SizedBox(height: 18),
                    _buildDataRow("Connected:", deviceData['connected']?.toString() ?? 'No', rotationAngle),
                    const SizedBox(height: 18),
                    _buildDataRow("Temperature:", "${deviceData['lastTemp'] ?? '0'}°C", rotationAngle),
                    const SizedBox(height: 18),
                    _buildDataRow("Flame Read:", deviceData['lastFlame']?.toString() ?? 'Normal', rotationAngle),
                    const SizedBox(height: 18),
                    _buildDataRow("State Level:", deviceData['status']?.toString() ?? 'Active', rotationAngle),
                  ],
                ),
              ),

              // --- الأزرار (تم رفعها للأعلى لتكون واضحة في الصفحة الواحدة) ---
              Positioned(
                top: 550, // تم رفع الموضع من أسفل الشاشة للأعلى
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر Cancel (الرجوع)
                    _buildButton("Cancel", const Color(0xFF9E122C), () => Navigator.pop(context)),
                    // زر Delete
                    _buildButton("Delete", const Color(0xFF8B0000), () {
                      // منطق الحذف
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, double angle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E122C),
          ),
        ),
        Transform.rotate(
          angle: angle,
          child: Container(
            width: 170,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF9E122C).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140, // جعل الزر أعرض قليلاً ليناسب التصميم
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}