import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlertManagementScreen extends StatefulWidget {
  const AlertManagementScreen({super.key});

  @override
  State<AlertManagementScreen> createState() => _AlertManagementScreenState();
}

class _AlertManagementScreenState extends State<AlertManagementScreen> {
  String? selectedColor;
  String? selectedCity;
  String? selectedDateRange;

  // الألوان مطابقة تماماً لما يتم إرساله من صفحة المستخدم
  final Map<String, Color> colorOptions = {
    'RED': const Color(0xFFE30000),
    'ORANGE': const Color(0xFFFF8800),
    'YELLOW': const Color(0xFFFFDC14),
  };

  final List<String> cities = ['Riyadh', 'Jeddah', 'Dammam', 'Makkah', 'Medina', 'Qassim'];
  final List<String> dateFilters = ['Today', 'This Week', 'This Month', 'This Year'];

  // بناء الاستعلام مع الفلاتر
  Query _buildFilteredQuery() {
    Query query = FirebaseFirestore.instance.collection('history');

    if (selectedColor != null) {
      query = query.where('alarmType', isEqualTo: selectedColor);
    }

    if (selectedCity != null) {
      query = query.where('city', isEqualTo: selectedCity);
    }

    if (selectedDateRange != null) {
      DateTime now = DateTime.now();
      DateTime startDate;
      if (selectedDateRange == 'Today') startDate = DateTime(now.year, now.month, now.day);
      else if (selectedDateRange == 'This Week') startDate = now.subtract(Duration(days: now.weekday - 1));
      else if (selectedDateRange == 'This Month') startDate = DateTime(now.year, now.month, 1);
      else startDate = DateTime(now.year, 1, 1);
      
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    return query.orderBy('timestamp', descending: true);
  }

  // نافذة تفاصيل الإنذار (Pop-up)
  void _showDetailsDialog(Map<String, dynamic> data, Color statusColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Container(width: 15, height: 15, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            const Text("Alert Details", style: TextStyle(color: Color(0xFF9E122C), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailItem(Icons.person, "User", data['userName'] ?? "Unknown"),
            _detailItem(Icons.location_on, "City", data['city'] ?? "Not specified"),
            _detailItem(Icons.thermostat, "Temp", "${data['temperature'] ?? '--'}°C"),
            _detailItem(Icons.check_circle, "Decision", data['decision'] ?? "No action"),
            _detailItem(Icons.calendar_today, "Date", data['date'] ?? "--"),
            _detailItem(Icons.access_time, "Time", data['time'] ?? "--"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFF9E122C))),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9E122C)),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            
            // أزرار الفلترة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorDropdown(),
                      _buildFilterDropdown("City", cities, selectedCity, (val) => setState(() => selectedCity = val)),
                      _buildFilterDropdown("Date", dateFilters, selectedDateRange, (val) => setState(() => selectedDateRange = val)),
                    ],
                  ),
                  if (selectedColor != null || selectedCity != null || selectedDateRange != null)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        selectedColor = null;
                        selectedCity = null;
                        selectedDateRange = null;
                      }),
                      icon: const Icon(Icons.refresh, size: 18, color: Colors.red),
                      label: const Text("Clear Filters", style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildFilteredQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No records found"));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      String type = (data['alarmType'] ?? 'YELLOW').toString().toUpperCase();
                      Color statusColor = colorOptions[type] ?? Colors.grey;

                      return GestureDetector(
                        onTap: () => _showDetailsDialog(data, statusColor),
                        child: _buildAlertTile(
                          statusColor: statusColor,
                          date: data['date'] ?? "--",
                          time: data['time'] ?? "--",
                          user: data['userName'] ?? 'User',
                          decision: data['decision'] ?? 'None',
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
    );
  }

  Widget _buildColorDropdown() {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF9E122C))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text("Color", style: TextStyle(fontSize: 12, color: Color(0xFF900B09), fontWeight: FontWeight.bold)),
          value: selectedColor,
          isExpanded: true,
          items: colorOptions.keys.map((String key) => DropdownMenuItem(
            value: key,
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: colorOptions[key], shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(key, style: const TextStyle(fontSize: 11)),
              ],
            ),
          )).toList(),
          onChanged: (val) => setState(() => selectedColor = val),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> items, String? currentVal, Function(String?) onChanged) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF9E122C))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF900B09), fontWeight: FontWeight.bold)),
          value: currentVal,
          isExpanded: true,
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 11)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF852221)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text('Alert Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF9E122C))),
        ],
      ),
    );
  }

  Widget _buildAlertTile({required Color statusColor, required String date, required String time, required String user, required String decision}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(width: 18, height: 18, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9E122C), fontSize: 16)),
                Text("$date | $time", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(decision, style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}