// ما شغلناها رسمي 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEditScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> userData;

  const UserEditScreen({super.key, required this.docId, required this.userData});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController nationalAddressController;
  late TextEditingController deviceController;
  
  String? selectedCity;
  final List<String> saudiCities = [
    'Riyadh', 'Jeddah', 'Dammam', 'Makkah', 'Madinah', 
    'Abha', 'Tabuk', 'Hail', 'Jazan', 'Najran', 'Al-Khobar'
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData['name'] ?? "");
    emailController = TextEditingController(text: widget.userData['email'] ?? "");
    phoneController = TextEditingController(text: widget.userData['phoneNumber'] ?? "");
    nationalAddressController = TextEditingController(text: widget.userData['nationalAddress'] ?? "");
    deviceController = TextEditingController(text: widget.userData['deviceId'] ?? "");
    selectedCity = widget.userData['city'];
  }

  // دالة الحفظ والتحديث
  Future<void> _updateUser() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.docId).update({
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'city': selectedCity,
        'nationalAddress': nationalAddressController.text,
        'deviceId': deviceController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User updated successfully! ✅")));
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // دالة حذف المستخدم مع نافذة تأكيد
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this user? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(widget.docId).delete();
              Navigator.pop(context); // إغلاق التنبيه
              Navigator.pop(context); // العودة لجدول الإدارة
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User deleted successfully")));
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      appBar: AppBar(
        title: const Text("User Manage-Edit", style: TextStyle(color: Color(0xFF9E122C), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("User Name:"),
            _buildTextField(nameController),

            _buildLabel("Email:"),
            _buildTextField(emailController),

            _buildLabel("Phone Number:"),
            _buildTextField(phoneController, isNumber: true),

            _buildLabel("City:"),
            _buildDropdown(),

            _buildLabel("National Address:"),
            _buildTextField(nationalAddressController, hint: "Letters & Numbers"),

            _buildLabel("Device ID:"),
            _buildTextField(deviceController),

            const SizedBox(height: 40),

            // أزرار Save و Cancel
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFF9E122C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Cancel", style: TextStyle(color: Color(0xFF9E122C), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E122C),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // زر الحذف (Delete) في الأسفل
            Center(
              child: TextButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text("Delete User Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(text, style: const TextStyle(color: Color(0xFF9E122C), fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController controller, {bool isNumber = false, String? hint}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCity,
          hint: const Text("Select City"),
          isExpanded: true,
          items: saudiCities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
          onChanged: (val) => setState(() => selectedCity = val),
        ),
      ),
    );
  }
}