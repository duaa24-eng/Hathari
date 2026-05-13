import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:hathari_app/screens/station_pages/station_history.dart';
import 'package:hathari_app/screens/station_pages/manage_station.dart'; 

class StationHome extends StatefulWidget {
  const StationHome({super.key});

  @override
  State<StationHome> createState() => _StationHomeState();
}

class _StationHomeState extends State<StationHome> {
  final Color mainRed = const Color(0xFF9E122C);
  final Color bgCream = const Color(0xFFFFF3EF);
  
  // المتغير المسؤول عن التبديل (0: تاريخ، 1: هوم، 2: منج ستيشن)
  int _selectedTabIndex = 1;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("Hathari_Device_001");
  final LatLng deviceLocation = const LatLng(24.7136, 46.6753);

  String _userName = "Loading..."; 
  String _stationCity = "";
  bool _isRejectedLocally = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) setState(() => _stationCity = doc.data()?['city'] ?? "");
      }

      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('deviceId', isEqualTo: 'Hathari_Device_001')
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        setState(() {
          _userName = userData['username'] ?? userData['userName'] ?? 'User';
        });
      } else {
        setState(() => _userName = "Unknown User");
      }
    } catch (e) {
      setState(() => _userName = "Error");
    }
  }

  Future<void> _acceptAndLogFire(String temp, String status) async {
    try {
      await FirebaseFirestore.instance.collection('fire_logs').add({
        'userName': _userName,
        'temperature': temp,
        'alarmType': status.toUpperCase() == "DANGER" ? "RED" : "ORANGE",
        'city': _stationCity,
        'date': DateFormat('yyyy/MM/dd').format(DateTime.now()),
        'time': DateFormat('hh:mm a').format(DateTime.now()),
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() => _isRejectedLocally = true);
    } catch (e) {
      debugPrint("Save Error: $e");
    }
  }

  // دالة لاختيار المحتوى الذي سيظهر في الـ body
  Widget _getSelectedPage() {
    switch (_selectedTabIndex) {
      case 0:
        return const stationHistoryScreen();
      case 2:
        return const ManageStationScreen(); 
      case 1:
      default:
        return _buildHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      body: _getSelectedPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeScreen() {
    return StreamBuilder(
      stream: _dbRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        double currentTemp = 0.0;
        bool hasWarning = false;
        Color alertColor = Colors.orange;
        String alertStatus = "high";

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          currentTemp = double.tryParse(data['temperature'].toString()) ?? 0.0;
          if (currentTemp < 35.0) _isRejectedLocally = false;
          if (currentTemp >= 35.0 && !_isRejectedLocally) {
            hasWarning = true;
            alertColor = currentTemp > 45.0 ? Colors.red : Colors.orange;
            alertStatus = currentTemp > 45.0 ? "danger" : "high";
          }
        }

        return Column(
          children: [
            const SizedBox(height: 60),
            Text('Hello Station', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: mainRed)),
            const Divider(indent: 40, endIndent: 40),
            _buildLegendRow(),
            const Divider(indent: 40, endIndent: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft, child: Text("Recent Activity", style: TextStyle(color: mainRed, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  hasWarning 
                    ? GestureDetector(
                        onTap: () => _showFireDetailsDialog("$currentTemp", alertStatus),
                        child: _alertItem(alertColor, "Temp: $currentTemp°C"),
                      )
                    : Text("No critical activity detected", style: TextStyle(color: mainRed.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
            Text("Active Fire Map", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: mainRed)),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(border: Border.all(color: mainRed), borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FlutterMap(
                    options: MapOptions(initialCenter: deviceLocation, initialZoom: 14),
                    children: [
                      TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'),
                      if (hasWarning) MarkerLayer(markers: [Marker(point: deviceLocation, child: Icon(Icons.local_fire_department, color: alertColor, size: 45))]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFireDetailsDialog(String temp, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Fire Alert - $_userName", style: TextStyle(color: mainRed)),
        content: Text("A fire has been detected at $_userName's location.\nTemperature: $temp°C"),
        actions: [
          TextButton(onPressed: () { setState(() => _isRejectedLocally = true); Navigator.pop(context); }, child: const Text("Ignore")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainRed),
            onPressed: () { Navigator.pop(context); _acceptAndLogFire(temp, status); }, 
            child: const Text("Accept", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _legendCircle(Colors.red, "Danger (+45°C)"),
    const SizedBox(width: 20),
    _legendCircle(Colors.orange, "Warning (+35°C)"),
  ]);

  Widget _legendCircle(Color c, String t) => Row(children: [CircleAvatar(backgroundColor: c, radius: 5), const SizedBox(width: 5), Text(t, style: TextStyle(color: mainRed, fontSize: 10, fontWeight: FontWeight.bold))]);

  Widget _alertItem(Color color, String subtitle) => Column(children: [
    Stack(alignment: Alignment.topCenter, children: [
      Container(margin: const EdgeInsets.only(top: 8), height: 60, width: 60, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.map_outlined, color: Colors.grey.shade400)),
      CircleAvatar(backgroundColor: color, radius: 6)
    ]),
    const SizedBox(height: 5),
    Text("New alert", style: TextStyle(color: mainRed, fontSize: 12, fontWeight: FontWeight.bold)),
    Text(subtitle, style: TextStyle(color: mainRed, fontSize: 10))
  ]);

  Widget _buildBottomNav() => Container(
    color: mainRed, 
    height: 70, 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, 
      children: [
        IconButton(
          icon: Icon(Icons.history, color: _selectedTabIndex == 0 ? Colors.white : Colors.white54, size: 30), 
          onPressed: () => setState(() => _selectedTabIndex = 0)
        ),
        IconButton(
          icon: Icon(Icons.home, color: _selectedTabIndex == 1 ? Colors.white : Colors.white54, size: 30), 
          onPressed: () => setState(() => _selectedTabIndex = 1)
        ),
        // تعديل هنا: صار يغير الـ index بدلاً من فتح صفحة جديدة
        IconButton(
          icon: Icon(Icons.settings, color: _selectedTabIndex == 2 ? Colors.white : Colors.white54, size: 30), 
          onPressed: () => setState(() => _selectedTabIndex = 2)
        ),
      ]
    )
  );
}