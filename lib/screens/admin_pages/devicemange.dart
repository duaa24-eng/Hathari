import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hathari_app/screens/admin_pages/devicemange_view.dart';

class DeviceManagement extends StatelessWidget {
  const DeviceManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF), 
      body: Stack(
        children: [
          // --- سهم الرجوع ---
          Positioned(
            top: 50, 
            left: 20, 
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // --- العنوان الرئيسي ---
          const Positioned(
            top: 98,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Device Management',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E122C),
                ),
              ),
            ),
          ),

          // --- منطقة الجدول ---
          Positioned(
            top: 200,
            left: 20,
            right: 20,
            bottom: 40,
            child: Column(
              children: [
                // رأس الجدول
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border.all(color: const Color(0xFF9E122C), width: 1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildHeaderCell('ID', flex: 2),
                      _buildDivider(),
                      _buildHeaderCell('User Name', flex: 3),
                      _buildDivider(),
                      _buildHeaderCell('Status', flex: 2),
                      _buildDivider(),
                      _buildHeaderCell('Action', flex: 2),
                    ],
                  ),
                ),

                // عرض البيانات (يدوياً + من الفايربيس)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('devices').snapshots(),
                    builder: (context, snapshot) {
                      List<Widget> deviceRows = [];

                      // 1. إضافة جهاز "حذاري 1" بالبيانات الافتراضية المطلوبة
                      deviceRows.add(_buildDeviceRow(
                        context,
                        id: "HATHARI-01",
                        name: "Reem", // اسم المستخدمة
                        status: "Active",
                        fullData: {
                          "deviceId": "HATHARI-01",
                          "userName": "Reem",
                          "connected": "Yes", // حالة الارتباط
                          "lastTemp": "29.4", // درجة الحرارة المطلوبة
                          "lastFlame": "0",    // قراءة اللهب المطلوبة
                          "status": "Active"
                        },
                      ));

                      // 2. إضافة الأجهزة من الفايربيس إن وجدت
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        for (var doc in snapshot.data!.docs) {
                          var data = doc.data() as Map<String, dynamic>;
                          if (data['deviceId'] != "HATHARI-01") {
                            deviceRows.add(_buildDeviceRow(
                              context,
                              id: data['deviceId']?.toString() ?? doc.id,
                              name: data['userName'] ?? 'Unknown',
                              status: data['status'] ?? 'Offline',
                              fullData: data,
                            ));
                          }
                        }
                      }

                      return ListView(
                        padding: EdgeInsets.zero,
                        children: deviceRows,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceRow(BuildContext context, {
    required String id, 
    required String name, 
    required String status, 
    required Map<String, dynamic> fullData
  }) {
    return Container(
      height: 55,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFF9E122C)),
          right: BorderSide(color: Color(0xFF9E122C)),
          bottom: BorderSide(color: Color(0xFF9E122C)),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(id, flex: 2),
          _buildDivider(),
          _buildDataCell(name, flex: 3),
          _buildDivider(),
          _buildStatusCell(status, flex: 2),
          _buildDivider(),
          Expanded(
            flex: 2,
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceManageView(
                        deviceId: id,
                        deviceData: fullData,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View',
                  style: TextStyle(
                    color: Color(0xFF9E122C),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9E122C)),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF9E122C)),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status, {required int flex}) {
    bool isActive = status.toLowerCase() == 'active' || status.toLowerCase() == 'online';
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          status.toUpperCase(),
          style: TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.bold, 
            color: isActive ? Colors.green : Colors.red
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: double.infinity, color: const Color(0xFF9E122C).withOpacity(0.3));
  }
}