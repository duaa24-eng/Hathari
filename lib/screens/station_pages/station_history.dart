import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// بكرا نسوي دليت لداتا بيس ونجرب عند الارسال تتحمل بيانات او لا
class stationHistoryScreen extends StatefulWidget {
  const stationHistoryScreen({super.key});

  @override
  State<stationHistoryScreen> createState() => _stationHistoryScreenState();
}

class _stationHistoryScreenState extends State<stationHistoryScreen> {
  String _stationCity = '';
  bool _isLoadingCity = true;

  @override
  void initState() {
    super.initState();
    _loadCity();
  }

  // جلب مدينة المحطة مرة واحدة لتسريع الفلترة
  Future<void> _loadCity() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (mounted) {
          setState(() {
            _stationCity = doc.data()?['city'] ?? '';
            _isLoadingCity = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCity = false);
    }
  }

  // دالة تحديث البيانات عند السحب للأعلى
  Future<void> _handleRefresh() async {
    await _loadCity();
    setState(() {}); // إعادة بناء الواجهة لجلب أحدث البيانات من الـ Stream
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: _isLoadingCity 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9E122C)))
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: const Color(0xFF9E122C),
              child: Stack(
                children: [
                  // العنوان بدون سهم العودة
                  const Positioned(
                    top: 60, left: 0, right: 0,
                    child: Center(
                      child: Text('History', 
                        style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 36, color: Color(0xFF9E122C))
                      )
                    ),
                  ),

                  // قائمة البلاغات
                  Positioned(
                    top: 140, bottom: 80, left: 0, right: 0,
                    child: StreamBuilder<QuerySnapshot>(
                      // نستخدمOrderBy لترتيب الأحدث أولاً
                      stream: FirebaseFirestore.instance
                          .collection('fire_logs')
                          .where('city', isEqualTo: _stationCity)
                          .orderBy('timestamp', descending: true)
                          .snapshots(), 
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF9E122C)));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text("No records found", style: TextStyle(color: Color(0xFF9E122C)))),
                            ],
                          );
                        }

                        final docs = snapshot.data!.docs;

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            var data = docs[index].data() as Map<String, dynamic>;
                            return FireLogItem(
                              userName: data['userName'] ?? data['username'] ?? 'Unknown',
                              temp: data['temperature']?.toString() ?? '--',
                              date: data['date'] ?? '--',
                              time: data['time'] ?? '--',
                              statusColor: data['alarmType'] == 'RED' ? const Color(0xFFE30000) : const Color(0xFFFF8800),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const Positioned(bottom: 20, left: 0, right: 0, child: StationLegend()),
                ],
              ),
            ),
      ),
    );
  }
}

class FireLogItem extends StatelessWidget {
  final String date, time, userName, temp;
  final Color statusColor;

  const FireLogItem({super.key, required this.date, required this.time, required this.userName, required this.temp, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
      ),
      child: Row(
        children: [
          Container(width: 15, height: 15, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(color: Color(0xFF900B09), fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Temp: $temp°C", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: const TextStyle(color: Color(0xFF900B09), fontSize: 13, fontWeight: FontWeight.w600)),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class StationLegend extends StatelessWidget {
  const StationLegend({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _dot(const Color(0xFFE30000), "Danger"),
      const SizedBox(width: 25),
      _dot(const Color(0xFFFF8800), "Warning"),
    ]);
  }
  Widget _dot(Color c, String t) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 8),
    Text(t, style: const TextStyle(fontSize: 14, color: Color(0xFF9E122C), fontWeight: FontWeight.bold)),
  ]);
}
// بكرا نسوي دليت لداتا بيس ونجرب عند الارسال تتحمل بيانات او لا