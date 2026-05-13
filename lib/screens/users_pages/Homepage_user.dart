import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:hathari_app/screens/admin_pages/guide.dart';
import 'package:hathari_app/screens/Notification.dart';
import 'package:hathari_app/screens/users_pages/history.dart';
import 'package:hathari_app/screens/users_pages/fire_instuctions.dart';
import 'package:hathari_app/screens/users_pages/user_account_management.dart';

class UserHome extends StatefulWidget {
  final String userName;
  final String password;
  const UserHome({super.key, this.userName = "User", this.password = ""});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("Hathari_Device_001");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _lastStatus = "SAFE";
  String _lastAlertTemp = "";
  bool _isPopupShowing = false;

  // --- دالة اتخاذ القرار وإرسال البلاغات ---
  Future<void> _handleUserDecision(String alarmType, String decision, String temp) async {
    try {
      if (_isPopupShowing && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _isPopupShowing = false;
      }

      String formattedTime = DateFormat('hh:mm a').format(DateTime.now());
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String statusKey = alarmType.toUpperCase();

      // 1. حفظ في سجل التاريخ (للكل)
      await _firestore.collection('history').add({
        'userName': widget.userName,
        'alarmType': statusKey,
        'decision': decision,
        'temperature': temp,
        'city': 'Riyadh',
        'time': formattedTime,
        'date': formattedDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. منطق الإرسال للمحطة (station_alerts)
      // يرسل إذا كان (أحمر وضغط Red) أو (برتقالي وضغط Call)
      bool shouldSendToStation = false;
      if (statusKey.contains("RED") && decision == "Red") {
        shouldSendToStation = true;
      } else if (statusKey.contains("ORANGE") && decision == "Call") {
        shouldSendToStation = true;
      }

      if (shouldSendToStation) {
        await _firestore.collection('station_alerts').add({
          'type': statusKey,
          'userName': widget.userName,
          'temperature': temp,
          'city': 'Riyadh',
          'status': 'Unresolved', // الحالة التي تظهر في صفحة السيشن هوم
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // 3. إعادة الجهاز لحالة الأمان
      await _dbRef.update({'status': 'SAFE'});
      
    } catch (e) {
      debugPrint("Decision Error: $e");
    }
  }

  void _checkStatusAndShowPopup(String status, String temp) {
    String s = status.toUpperCase().trim();
    if (s == "SAFE") {
      _lastStatus = "SAFE";
      _lastAlertTemp = "";
      return;
    }
    if (_isPopupShowing) return;

    if (s != _lastStatus || _lastAlertTemp.isEmpty) {
      _lastStatus = s;
      _lastAlertTemp = temp;
      _isPopupShowing = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildCustomAlarmDialog(status, temp),
        ).then((_) => _isPopupShowing = false);
      });
    }
  }

  // --- بناء بوب أب الإنذار حسب نوعه ---
  Widget _buildCustomAlarmDialog(String type, String temp) {
    Color alarmColor;
    String mainButtonLabel;
    final String statusKey = type.trim().toUpperCase();

    // إعدادات اللون والمسمى الأساسي
    if (statusKey.contains("RED")) {
      alarmColor = const Color(0xFFE30000);
      mainButtonLabel = "Red";
    } else if (statusKey.contains("ORANGE")) {
      alarmColor = const Color(0xFFFF8800);
      mainButtonLabel = "Orange";
    } else {
      alarmColor = const Color(0xFFFFDC14);
      mainButtonLabel = "Yellow";
    }

    const Color textRed = Color(0xFF9E122C);
    
    // منطق توزيع الأزرار المطلوب
    bool isOrange = statusKey.contains("ORANGE");
    bool isRed = statusKey.contains("RED");

    return Material(
      color: Colors.transparent,
      child: Center(
        child: SizedBox(
          width: 393, height: 852,
          child: Stack(
            children: [
              // مستطيل الإنذار المائل
              Positioned(
                left: 75, top: 206,
                child: Transform.rotate(
                  angle: 0.37 * (math.pi / 180),
                  child: Container(width: 233, height: 305, decoration: BoxDecoration(color: alarmColor, borderRadius: BorderRadius.circular(5))),
                ),
              ),
              // بطاقة البيانات البيضاء
              Positioned(
                left: 47, top: 293,
                child: Transform.rotate(
                  angle: 0.45 * (math.pi / 180),
                  child: Container(
                    width: 294, height: 243, color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.local_fire_department, color: textRed, size: 45),
                          SizedBox(width: 10),
                          Text("Fire Detected?", style: TextStyle(color: textRed, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.thermostat, color: textRed, size: 45),
                          const SizedBox(width: 10),
                          Text("$temp°C", style: const TextStyle(color: textRed, fontSize: 24, fontWeight: FontWeight.bold)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),

              // --- توزيع الأزرار بناءً على الحالة ---
              
              // زر Fake (دائماً موجود يسار)
              Positioned(left: 39, top: 539, child: _popupActionButton("Fake", statusKey, temp)),

              // زر الحالة (Red أو Orange) دائماً موجود يمين
              Positioned(left: 198, top: 539, child: _popupActionButton(mainButtonLabel, statusKey, temp)),

              // زر Call يظهر فقط في حالة البرتقالي (في المنتصف بالأسفل)
              if (isOrange)
                Positioned(left: 393/2 - 79, top: 610, child: _popupActionButton("Call", statusKey, temp, isEmergencyCall: true)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popupActionButton(String label, String type, String temp, {bool isEmergencyCall = false}) {
    return GestureDetector(
      onTap: () {
        if (isEmergencyCall) _makePhoneCall('998');
        _handleUserDecision(type, label, temp); 
      },
      child: Container(
        width: 158, height: 58,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF9E122C), width: 2)),
        child: Center(child: Text(label, style: const TextStyle(color: Color(0xFF9E122C), fontSize: 24, fontWeight: FontWeight.bold, decoration: TextDecoration.none))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color mainRed = Color(0xFF9E122C);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: Stack(
        children: [
          Positioned(top: 70, left: 20, child: Text('Hello ${widget.userName}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: mainRed))),
          StreamBuilder(
            stream: _dbRef.onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                String temp = data['temperature']?.toString() ?? "0";
                String status = data['status']?.toString() ?? "SAFE";
                bool isFire = data['flame'] == 1 || data['flame'] == true;
                
                _checkStatusAndShowPopup(status, temp);

                return Stack(
                  children: [
                    _buildSensorCard(context, left: 20, top: 150, label: 'Temperature:\n$temp°C', updateTime: 'Status: $status', icon: Icons.thermostat, isAlert: (!status.toUpperCase().contains("SAFE"))),
                    _buildSensorCard(context, right: 20, top: 150, label: 'Flame Status:\n${isFire ? "Detected" : "Safe"}', updateTime: 'Last Update: ${DateFormat('hh:mm a').format(DateTime.now())}', icon: Icons.local_fire_department, isAlert: isFire),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator(color: mainRed));
            },
          ),
          _buildActionButton(context, label: 'Call Station', top: 426, icon: Icons.phone, onTap: () => _makePhoneCall('998')),
          _buildActionButton(context, label: 'History', top: 510, icon: Icons.history, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FireHistoryScreen()))),
          _buildActionButton(context, label: 'Fire instruction', top: 594, icon: Icons.menu_book, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FireInstructionsScreen(username: widget.userName, password: widget.password)))),
          _buildActionButton(context, label: 'Send Notification', top: 678, icon: Icons.notifications_active, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SendNotificationScreen()))),
          
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 70, decoration: const BoxDecoration(color: mainRed, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                IconButton(icon: const Icon(Icons.settings, color: Colors.white, size: 30), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageAccountScreen()))),
                const Icon(Icons.home, color: Colors.white70, size: 30),
                IconButton(icon: const Icon(Icons.help_outline, color: Colors.white, size: 30), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuideScreen()))),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Widget _buildSensorCard(BuildContext context, {double? left, double? right, required double top, required String label, required String updateTime, required IconData icon, bool isAlert = false}) {
    return Positioned(top: top, left: left, right: right, child: Column(children: [
      Container(width: 155, height: 155, decoration: BoxDecoration(color: isAlert ? const Color(0xFFFFEBEE) : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Icon(icon, size: 80, color: isAlert ? Colors.red : const Color(0xFF9E122C))),
      const SizedBox(height: 10),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFF9E122C), fontWeight: FontWeight.bold)),
      Text(updateTime, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]));
  }

  Widget _buildActionButton(BuildContext context, {required String label, required double top, required IconData icon, VoidCallback? onTap}) {
    return Positioned(top: top, left: MediaQuery.of(context).size.width / 2 - 145.5, child: GestureDetector(onTap: onTap, child: Container(width: 291, height: 51, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF9E122C), size: 24), const SizedBox(width: 10), Text(label, style: const TextStyle(fontSize: 22, color: Color(0xFF9E122C), fontWeight: FontWeight.w500))]))));
  }
}