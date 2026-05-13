//done 21/4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestationRequest extends StatefulWidget {
  const FirestationRequest({super.key});

  @override
  State<FirestationRequest> createState() => _FirestationRequestState();
}

class _FirestationRequestState extends State<FirestationRequest> {
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _docLinkController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedCity;
  final List<String> _cities = [
    "Riyadh", "Dammam", "Jeddah", "Makkah", "Medina", 
    "Khobar", "Abha", "Tabuk", "Hail", "Jazan", "Hafar Al-Batin"
  ];

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _sendRequest() async {
    if (_stationNameController.text.isEmpty ||
        _selectedCity == null ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _docLinkController.text.isEmpty) {
      _showSnackBar(' Please fill in all blanks', Colors.red);
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showSnackBar('Invalid email', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('station_requests').add({
        'stationName': _stationNameController.text.trim(),
        'city': _selectedCity,
        'email': _emailController.text.trim(),
        'password': _passwordController.text, 
        'fileUrl': _docLinkController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSnackBar('Request submitted successfuly ✅', Colors.green);
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      _showSnackBar(' error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: color,
        duration: const Duration(seconds: 2), 
      ),
    );
  }

  @override
  void dispose() {
    _stationNameController.dispose();
    _emailController.dispose();
    _docLinkController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), 
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'New Request',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF9E122C)),
                ),
              ),
              const SizedBox(height: 30),

              _buildLabel('Station Name:'),
              _buildInputField(_stationNameController, 'Enter station name'),

              const SizedBox(height: 15),
              _buildLabel('Email Address:'),
              _buildInputField(_emailController, 'example@mail.com', keyboardType: TextInputType.emailAddress),

              const SizedBox(height: 15),
              _buildLabel('Password:'),
              _buildPasswordField(),

              const SizedBox(height: 15),
              _buildLabel('City:'),
              _buildCityDropdown(),

              const SizedBox(height: 15),
              _buildLabel('Drive Link:'),
              _buildInputField(_docLinkController, 'Paste documentation link'),

              const SizedBox(height: 40),
              
              // زر الإرسال المحسن
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E122C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Send Request', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9E122C))),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12), 
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: 'Minimum 6 characters',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9E122C)),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text("Choose your city", style: TextStyle(fontSize: 14)),
          value: _selectedCity,
          isExpanded: true,
          items: _cities.map((String city) {
            return DropdownMenuItem<String>(value: city, child: Text(city));
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedCity = newValue),
        ),
      ),
    );
  }
}