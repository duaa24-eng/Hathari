import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FireHistoryScreen extends StatelessWidget {
  const FireHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: Stack(
          children: [
            // العنوان الرئيسي (History)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'History',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: Color(0xFF9E122C),
                  ),
                ),
              ),
            ),
            
            // زر العودة للخلف
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // عرض السجلات من Firestore
            Positioned(
              top: 150,
              bottom: 100,
              left: 0,
              right: 0,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('history')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text("Error loading records"));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF9E122C)));
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No records available yet.", 
                        style: TextStyle(color: Color(0xFF9E122C), fontSize: 18)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      
                      // معالجة الوقت والتاريخ
                      DateTime? dateTime = (data['timestamp'] as Timestamp?)?.toDate();
                      String dateStr = dateTime != null ? DateFormat('yyyy/MM/dd').format(dateTime) : '--/--';
                      String timeStr = dateTime != null ? DateFormat('hh:mm a').format(dateTime) : '--:--';
                      
                      // جلب نوع الإنذار والقرار
                      String alarmType = (data['alarmType'] ?? 'SAFE').toString().toUpperCase();
                      String decision = (data['decision'] ?? 'Unknown').toString();

                      return FireLogItem(
                        date: dateStr,
                        time: timeStr,
                        temp: data['temperature']?.toString() ?? '0',
                        decision: decision,
                        // إرسال القرار للدالة لتحديد هل نستخدم الرمادي أم اللون الأصلي
                        statusColor: _getStatusColor(alarmType, decision), 
                      );
                    },
                  );
                },
              ),
            ),

            // قائمة توضيح الألوان في الأسفل (تمت إضافة الفيك هنا)
            const Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: BottomLegend(),
            ),
          ],
        ),
      ),
    );
  }
  
  // دالة مطورة لتغيير لون الدائرة بناءً على النوع والقرار
  Color _getStatusColor(String type, String decision) {
    // إذا كان المستخدم ضغط على Fake، يظهر اللون رمادي بغض النظر عن قوة الإنذار
    if (decision.toLowerCase() == 'fake') {
      return Colors.grey; 
    }
    
    // الألوان الأصلية لبقية القرارات
    if (type.contains('RED')) return const Color(0xFFE30000); 
    if (type.contains('ORANGE')) return const Color(0xFFFF8800); 
    if (type.contains('YELLOW')) return const Color(0xFFFFDC14); 
    
    return Colors.grey;
  }
}

class FireLogItem extends StatelessWidget {
  final String date;
  final String time;
  final String temp;
  final String decision;
  final Color statusColor;

  const FireLogItem({
    super.key, 
    required this.date, 
    required this.time, 
    required this.statusColor,
    required this.temp,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 15),
          
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(color: Color(0xFF900B09), fontSize: 16, fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.thermostat, size: 16, color: statusColor),
                Text(" $temp°", style: const TextStyle(color: Color(0xFF900B09), fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Text(
              decision, 
              textAlign: TextAlign.end,
              style: TextStyle(
                color: statusColor, 
                fontWeight: FontWeight.bold, 
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomLegend extends StatelessWidget {
  const BottomLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // زيادة الوضوح قليلاً
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(const Color(0xFFE30000), "Red"),
          _legendItem(const Color(0xFFFF8800), "Orange"),
          _legendItem(const Color(0xFFFFDC14), "Yellow"),
          _legendItem(Colors.grey, "Fake/Safe"), // إضافة توضيح الرمادي
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF900B09), fontWeight: FontWeight.bold)),
      ],
    );
  }
}