//done
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hathari_app/screens/admin_pages/noti_reaply.dart'; 

class ReportDetailsScreen extends StatelessWidget {
  final String subjectTitle;
  final String type;
  final String senderEmail;
  final String description;
  final String deviceId;

  const ReportDetailsScreen({
    super.key,
    required this.subjectTitle,
    required this.type,
    required this.senderEmail,
    required this.description,
    this.deviceId = "Null",
  });

  Stream<bool> _checkIfReplied() {
    String docId = "${senderEmail}_$subjectTitle".replaceAll(RegExp(r'[.#$\[\]]'), '_');
    return FirebaseFirestore.instance
        .collection('replies')
        .doc(docId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 customTransform = Matrix4.identity()..setEntry(0, 1, 0.01)..setEntry(1, 0, -0.01);
    final double rotationAngle = 0.45 * (math.pi / 180);
    const Color mainRed = Color(0xFF9E122C);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: Stack(
          children: [
          
            Positioned(
              top: 20,
              right: -250, // وضعته جهة اليمين ليناسب نمط شاشة الإشعارات لديك
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: mainRed, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Positioned(
            top: 50, 
            left: 20, 
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  subjectTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    color: mainRed, 
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),
            ),

            
            _buildLabel("Status:", 135),
            _buildLabel("Type:", 190),
            _buildLabel("Email:", 253),
            _buildLabel("Device ID:", 314),
            _buildLabel("Description:", 440),

            
            StreamBuilder<bool>(
              stream: _checkIfReplied(),
              builder: (context, snapshot) {
                bool isReplied = snapshot.data ?? false;
                return _buildDataContent(
                  top: 130, 
                  angle: rotationAngle, 
                  value: isReplied ? "Replied" : "Pending",
                  textColor: isReplied ? Colors.green[700]! : mainRed,
                );
              },
            ),

        
            _buildDataContent(top: 185, angle: rotationAngle, value: type),
            _buildDataContent(top: 248, angle: rotationAngle, value: senderEmail),
            _buildDataContent(top: 309, angle: rotationAngle, value: deviceId),

            // --- صندوق الوصف ---
            Positioned(
              top: 490,
              left: (MediaQuery.of(context).size.width / 2) - 150,
              child: Transform(
                transform: customTransform,
                child: Container(
                  width: 300,
                  height: 150,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
                  ),
                  child: SingleChildScrollView(
                    child: Text(description, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  ),
                ),
              ),
            ),

            // --- زر الرد فقط في الأسفل ---
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: _buildActionButton("Reply", customTransform, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminReplyScreen(email: senderEmail, subject: subjectTitle),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataContent({required double top, required double angle, required String value, Color textColor = Colors.black}) {
    return Positioned(
      top: top,
      right: 30,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 210,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Colors.white,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double top) => Positioned(
        top: top,
        left: 20,
        child: Text(text, style: const TextStyle(fontSize: 18, color: Color(0xFF9E122C), fontWeight: FontWeight.bold)),
      );

  Widget _buildActionButton(String label, Matrix4 transform, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Transform(
        transform: transform,
        child: Container(
          width: 150, 
          height: 50,
          color: const Color(0xFF9E122C),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}