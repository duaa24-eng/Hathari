//done
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:hathari_app/screens/admin_pages/noti_view.dart'; 

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double rotationAngle = 0.45 * (math.pi / 180);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
            top: 50, 
            left: 20, 
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
              onPressed: () => Navigator.pop(context),
            ),
          ),

            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9E122C),
                  ),
                ),
              ),
            ),

            // --- جلب البيانات الحية من Firebase ---
            Padding(
              padding: const EdgeInsets.only(top: 180),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reports') 
                    .orderBy('timestamp', descending: true) 
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF9E122C)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No new notifications",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var reportData = doc.data() as Map<String, dynamic>;

                      String subjectText = reportData['subject'] ?? "New Report";
                      String senderEmail = reportData['senderEmail'] ?? "No Email";

                      return NotificationTile(
                        subject: subjectText,
                        email: senderEmail,
                        angle: rotationAngle,
                        onTap: () {
                          // إرسال جميع البيانات لصفحة التفاصيل
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetailsScreen(
                                subjectTitle: subjectText,
                                type: reportData['type'] ?? "Unknown",
                                senderEmail: senderEmail,
                                description: reportData['description'] ?? "No Description",
                                deviceId: reportData['senderId'] ?? "N/A",
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String subject;
  final String email;
  final double angle;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.subject,
    required this.email,
    required this.angle,
    required this.onTap,
  });

  // دالة للتحقق مما إذا كان هناك رد محفوظ في الـ Database
  Stream<bool> _isRepliedStream() {
    // توحيد المعرف (ID) كما فعلنا في صفحة الرد
    String docId = "${email}_$subject".replaceAll(RegExp(r'[.#$\[\]]'), '_');
    return FirebaseFirestore.instance
        .collection('replies')
        .doc(docId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 85,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الخلفية المائلة البيضاء
            Transform.rotate(
              angle: angle,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
            
            // محتوى البطاقة (العنوان وحالة الرد)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E122C),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // التحقق من حالة الرد وعرض النص الأخضر الصغير
                        StreamBuilder<bool>(
                          stream: _isRepliedStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data == true) {
                              return const Text(
                                "✓ Replied",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    width: 45,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E122C),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}