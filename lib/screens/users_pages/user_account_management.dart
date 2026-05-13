import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _wifiNameController = TextEditingController();
  final TextEditingController _wifiPassController = TextEditingController();

  final List<String> _saudiCities = [
    'Riyadh', 'Jeddah', 'Dammam', 'Khobar', 'Dhahran', 
    'Mecca', 'Medina', 'Abha', 'Taif', 'Tabuk'
  ];

  String? _selectedCity;
  bool _isLoading = true;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _usernameController.text = data['userName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _wifiNameController.text = data['wifiName'] ?? '';
          _wifiPassController.text = data['wifiPassword'] ?? '';
          
          String? cityFromDb = data['city'];
          if (cityFromDb != null && cityFromDb.isNotEmpty) {
            if (!_saudiCities.contains(cityFromDb)) {
              _saudiCities.add(cityFromDb);
            }
            _selectedCity = cityFromDb;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading data: $e");
    }
  }

  // --- دالة تسجيل الخروج وتوجيه اليوزر لصفحة الـ login ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Log Out", style: TextStyle(color: Color(0xFF9E122C), fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out from Hathari?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9E122C)),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  // هنا تم استخدام 'login' كما طلبتِ للرجوع لصفحة تسجيل الدخول
                  Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
                }
              } catch (e) {
                debugPrint("Logout Error: $e");
              }
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- دالة حذف الحساب وتوجيه اليوزر لصفحة الـ login ---
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("This action is permanent! All your data and device settings will be deleted forever."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                String uid = _currentUser!.uid;

                // 1. حذف البيانات من Firestore
                await FirebaseFirestore.instance.collection('users').doc(uid).delete();

                // 2. حذف المستخدم من نظام المصادقة
                await _currentUser?.delete();

                if (mounted) {
                  // الرجوع لصفحة 'login' بعد الحذف بنجاح
                  Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("For security, please log in again before deleting your account."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text("Delete Forever", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({
        'userName': _usernameController.text,
        'phoneNumber': _phoneController.text,
        'wifiName': _wifiNameController.text,
        'wifiPassword': _wifiPassController.text,
        'city': _selectedCity,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changes saved successfully!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainRed = Color(0xFF9E122C);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: mainRed))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: mainRed),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Center(
                      child: Text(
                        'Manage My Account',
                        style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 28, color: mainRed),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildInputField("User Name:", _usernameController),
                    _buildInputField("Email:", _emailController, enabled: false),
                    
                    const SizedBox(height: 20),
                    const Text('Device Setting', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 24, color: mainRed)),
                    const SizedBox(height: 15),

                    _buildInputField("Phone Number:", _phoneController),
                    _buildInputField("Wifi Name:", _wifiNameController),
                    _buildInputField("Wifi Password:", _wifiPassController),
                    
                    const Text("City:", style: TextStyle(fontSize: 18, color: mainRed)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCity,
                          isExpanded: true,
                          hint: const Text("Select City"),
                          items: _saudiCities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                          onChanged: (val) => setState(() => _selectedCity = val),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700], 
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _showLogoutDialog,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: mainRed), 
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            child: const Text("Log Out", style: TextStyle(color: mainRed, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _showDeleteAccountDialog,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red), 
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            child: const Text("Delete Account", style: TextStyle(color: Colors.red, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, color: Color(0xFF9E122C))),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none, 
                contentPadding: EdgeInsets.symmetric(horizontal: 10)
              ),
            ),
          ),
        ],
      ),
    );
  }
}