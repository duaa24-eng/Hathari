import 'package:flutter/material.dart';
import 'dart:math' as math; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:hathari_app/screens/admin_pages/setting_admin.dart';
import 'package:hathari_app/screens/admin_pages/noti.dart'; 

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const double designWidth = 393.0;
    const double designHeight = 852.0;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: Center(
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: Stack(
            children: [
              // العنوان
              Positioned(
                left: (designWidth / 2) - 105,
                top: 40,
                child: const Text(
                  'Hello Admin',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF9E122C),
                  ),
                ),
              ),

              Positioned(
                top: 95, left: 0, right: 0,
                child: Container(height: 1.5, color: const Color(0xFF9E122C)),
              ),

              // 1. عدد المستخدمين (Role: user)
              Positioned(left: 30, top: 115, child: _buildLabel('Users')),
              _buildCounterField(
                top: 110,
                left: 140,
                stream: firestore.collection('users').where('role', isEqualTo: 'user').snapshots(),
              ),

              // 2. عدد الأجهزة (التي لديها deviceId)
              Positioned(left: 30, top: 165, child: _buildLabel('Devices')),
              _buildCounterField(
                top: 160,
                left: 140,
                stream: firestore.collection('users').where('deviceId', isNotEqualTo: "").snapshots(),
              ),

              Positioned(left: 30, top: 225, child: _buildLabel('Alert Numbers')),

              // 3. أرقام الإنذارات (معدلة لتطابق نصوص قاعدة البيانات في الصور)
              _buildAlertItem(
                topPos: 270, 
                circleColor: const Color(0xFFE30000), 
                status: 'FIRE RED', // تأكدي من الاسم في الفايربيس للآليرت الأحمر
                firestore: firestore
              ),
              _buildAlertItem(
                topPos: 325, 
                circleColor: const Color(0xFFFF8800), 
                status: 'ORANGE', 
                firestore: firestore
              ),
              _buildAlertItem(
                topPos: 380, 
                circleColor: const Color(0xFFFFDC14), 
                status: 'WARNING YELLOW', // تم التعديل بناءً على الصورة الرابعة
                firestore: firestore
              ),
              _buildAlertItem(
                topPos: 435, 
                circleColor: const Color(0xFFAA9898), 
                status: 'FAULT', 
                firestore: firestore
              ),

              // 4. قسم الإشعارات (التقارير المرسلة من اليوزر)
              Positioned(left: 30, top: 505, child: _buildLabel('New Notifications')),
              _buildNotificationBox(context, topPos: 545, firestore: firestore),

              // البار السفلي
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  // دالة العدادات (Users & Devices)
  Widget _buildCounterField({required double top, required double left, required Stream<QuerySnapshot> stream}) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: 0.45 * (math.pi / 180),
        child: Container(
          width: 210,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9E122C)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // دالة الإنذارات (معدلة للقراءة من كولكشن history)
  Widget _buildAlertItem({required double topPos, required Color circleColor, required String status, required FirebaseFirestore firestore}) {
    return Positioned(
      top: topPos,
      left: 30,
      right: 30,
      child: Row(
        children: [
          Container(width: 35, height: 35, decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle)),
          const SizedBox(width: 15),
          Expanded(
            child: Transform.rotate(
              angle: 0.45 * (math.pi / 180),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  // تم التعديل ليكون الكولكشن هو history بناءً على الصورة الرابعة
                  stream: firestore.collection('history').where('alarmType', isEqualTo: status).snapshots(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Center(
                      child: Text(
                        count.toString(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF9E122C)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // صندوق الإشعارات المربوط بـ reports
  Widget _buildNotificationBox(BuildContext context, {required double topPos, required FirebaseFirestore firestore}) {
    return Positioned(
      top: topPos,
      left: 30,
      right: 30,
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminNotificationsScreen())),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('reports').orderBy('timestamp', descending: true).limit(3).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text("No new notifications", style: TextStyle(color: Colors.grey)));

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(), 
                padding: const EdgeInsets.all(15),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.mail_outline, color: Color(0xFF9E122C), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "${data['subject'] ?? 'Notification'}",
                            style: const TextStyle(color: Color(0xFF9E122C), fontWeight: FontWeight.w600, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      bottom: -15, left: -20, right: -20,
      child: Transform.rotate(
        angle: 0.45 * (math.pi / 180),
        child: Container(
          height: 100,
          color: const Color(0xFF9E122C),
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 32),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 38),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminNotificationsScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9E122C)),
  );
}
//finallyyy 11/05/2026 the end 