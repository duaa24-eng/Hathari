//done 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hathari_app/screens/admin_pages/view_station.dart'; 

class StationManagement extends StatelessWidget {
  const StationManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: Stack(
        children: [
          const Positioned(
            top: 98, left: 0, right: 0,
            child: Center(
              child: Text('Station Management', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Color(0xFF9E122C))),
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
            top: 200, left: 10, right: 10, bottom: 50,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFF9E122C)), color: Colors.white.withOpacity(0.5)),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Center(child: Text('Name', style: _headerStyle))),
                      Expanded(flex: 2, child: Center(child: Text('City', style: _headerStyle))),
                      Expanded(flex: 2, child: Center(child: Text('Status', style: _headerStyle))),
                      Expanded(flex: 1, child: Center(child: Text('Action', style: _headerStyle))),
                    ],
                  ),
                ),
                
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('station_requests').orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No requests found."));

                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;
                          String status = data['status'] ?? 'Pending';
                          return Container(
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF9E122C))), color: Colors.white.withOpacity(0.3)),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Center(child: Text(data['stationName'] ?? '', style: _cellStyle))),
                                Expanded(flex: 2, child: Center(child: Text(data['city'] ?? '', style: _cellStyle))),
                                Expanded(flex: 2, child: Center(child: Text(status.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getStatusColor(status))))),
                                Expanded(
                                  flex: 1,
                                  child: TextButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StationManageView(
                                      stationName: data['stationName'],
                                      city: data['city'],
                                      docId: docs[index].id,
                                      stationEmail: data['email'],
                                      stationPassword: data['password'],
                                      fileUrl: data['fileUrl'] ?? '',
                                    ))),
                                    child: const Text('View', style: TextStyle(color: Color(0xFF9E122C), decoration: TextDecoration.underline)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase() == 'approved') return Colors.green;
    if (status.toLowerCase() == 'rejected') return Colors.red;
    return Colors.orange;
  }

  static const _headerStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9E122C));
  static const _cellStyle = TextStyle(fontSize: 14, color: Color(0xFF9E122C));
}