import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:hathari_app/screens/Notification.dart';
import 'package:hathari_app/screens/users_pages/history.dart';
import 'package:hathari_app/screens/users_pages/fire_instuctions.dart';
import 'package:hathari_app/screens/admin_pages/guide.dart';
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
  bool _isPopupShowing = false;
  bool _isConfirmPopupShowing = false; 
  bool _isArrivedConfirmed = false;

  @override
  void initState() {
    super.initState();
    _listenForStationResponse();
  }
  void _listenForStationResponse() {
    _firestore
        .collection('station_alerts')
        .where('userName', isEqualTo: widget.userName)
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty && !_isConfirmPopupShowing) {
        _isConfirmPopupShowing = true;
        String docId = snapshot.docs.first.id;
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildStationConfirmedPopup(docId),
        ).then((_) => _isConfirmPopupShowing = false);
      }
    });
  }

  Widget _buildStationConfirmedPopup(String docId) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF9E122C),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emergency_share, color: Colors.white, size: 50),
              const SizedBox(height: 20),
              const Text("Station Confirmed", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text(
                "Do you want to confirm the firefighter station Team’s arrival to your location?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _popupConfirmButton("Cancel", Colors.white, const Color(0xFF9E122C), () => Navigator.pop(context)),
                  _popupConfirmButton("Confirm", const Color(0xFFFFF3EF), const Color(0xFF9E122C), () async {
                    await _firestore.collection('station_alerts').doc(docId).update({'status': 'Resolved'});
                    setState(() {
                      _isArrivedConfirmed = true; // تفعيل واجهة الوصول
                    });
                    Navigator.pop(context);
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 3. واجهة "تم وصول الفريق" (Arrived Confirm View)
  Widget _buildArrivedConfirmView() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3EF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          const Text("Success!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF9E122C))),
          const SizedBox(height: 10),
          const Text("The Team has arrived safely.", style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => setState(() => _isArrivedConfirmed = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(color: const Color(0xFF9E122C), borderRadius: BorderRadius.circular(10)),
              child: const Text("Back to Home", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color mainRed = Color(0xFF9E122C);
    
    // إذا ضغط اليوزر تأكيد، نعرض واجهة الوصول، غير كذا نعرض الهوم العادي
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: _isArrivedConfirmed 
          ? _buildArrivedConfirmView() 
          : Stack(
              children: [
                Positioned(top: 70, left: 20, child: Text('Hello ${widget.userName}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: mainRed))),
                
                StreamBuilder(
                  stream: _dbRef.onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                      final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                      String temp = data['temperature']?.toString() ?? "0";
                      String status = data['status']?.toString().toUpperCase() ?? "SAFE";
                      bool isFire = data['flame'] == 1 || data['flame'] == true;
                      
                      _checkStatusAndShowPopup(status, temp);

                      return Stack(
                        children: [
                          _buildSensorCard(context, left: 20, top: 150, label: 'Temperature:\n$temp°C', updateTime: 'Status: $status', icon: Icons.thermostat, isAlert: (status != "SAFE")),
                          _buildSensorCard(context, right: 20, top: 150, label: 'Flame Status:\n${isFire ? "Detected" : "Safe"}', updateTime: 'Updated: ${DateFormat('hh:mm a').format(DateTime.now())}', icon: Icons.local_fire_department, isAlert: isFire),
                        ],
                      );
                    }
                    return const Center(child: CircularProgressIndicator(color: mainRed));
                  },
                ),

                // أزرار التحكم
                _buildActionButton(context, label: 'Call Station', top: 426, icon: Icons.phone, onTap: () => _makePhoneCall('998')),
                _buildActionButton(context, label: 'History', top: 510, icon: Icons.history, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FireHistoryScreen()))),
                _buildActionButton(context, label: 'Fire instruction', top: 594, icon: Icons.menu_book, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FireInstructionsScreen(username: widget.userName, password: widget.password)))),
                _buildActionButton(context, label: 'Send Notification', top: 678, icon: Icons.notifications_active, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SendNotificationScreen()))),
                
                // Bottom Navigation
                _buildBottomNav(mainRed),
              ],
            ),
    );
  }

  // --- دوال مساعدة ---
  
  void _checkStatusAndShowPopup(String status, String temp) {
    if (status == "SAFE") { _lastStatus = "SAFE"; return; }
    if (_isPopupShowing) return;
    if (status != _lastStatus) {
      _lastStatus = status;
      _isPopupShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(context: context, barrierDismissible: false, builder: (context) => _buildCustomAlarmDialog(status, temp)).then((_) => _isPopupShowing = false);
      });
    }
  }

  Widget _buildCustomAlarmDialog(String type, String temp) {
    return Material(
      color: Colors.transparent,
      child: Center(child: Text("Alarm: $type - $temp°C", style: const TextStyle(color: Colors.red, fontSize: 30, fontWeight: FontWeight.bold))),
    );
  }

  Widget _popupConfirmButton(String label, Color bg, Color textCol, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, height: 40,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: textCol)),
        child: Center(child: Text(label, style: TextStyle(color: textCol, fontWeight: FontWeight.bold))),
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

  Widget _buildBottomNav(Color mainRed) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 70, decoration: BoxDecoration(color: mainRed, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageAccountScreen()))),
          const Icon(Icons.home, color: Colors.white70),
          IconButton(icon: const Icon(Icons.help_outline, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuideScreen()))),
        ]),
      ),
    );
  }
}