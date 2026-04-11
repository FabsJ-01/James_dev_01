import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  
  // Para sa Eye Icon visibility logic
  bool _obscureNewPass = true;
  bool _obscureRetypePass = true;
  bool _isLoading = false;

  // --- PASSWORD VALIDATION LOGIC ---
  // Kailagan may eye icon doon para makita password na pinapalitan 
  // then atleast 8 character lower/upper case.
  bool _isPasswordValid(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasMinLength = password.length >= 8;
    return hasUppercase && hasLowercase && hasMinLength;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return; // Check kung valid ang form

    if (_newPasswordController.text != _retypePasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    if (!_isPasswordValid(_newPasswordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password must be 8+ characters, with Upper & Lower case!"),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Tandaan: Sa Firebase, ang sensitive operations gaya ng pagpapalit ng password 
        // ay nangangailangan minsan ng "Recent Login".
        await user.updatePassword(_newPasswordController.text);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Password Changed Successfully!"),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context); // Bumalik sa Profile Page
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to change password.";
      if (e.code == 'requires-recent-login') {
        errorMessage = "Please logout and login again before changing password for security.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // GlobalKey para sa validation
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Set a new password for your account.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              // --- NEW PASSWORD FIELD (MAY EYE ICON) ---
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPass, // Visibility toggling
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNewPass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureNewPass = !_obscureNewPass; // Toggle visibility
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter new password.";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- RETYPE PASSWORD FIELD (MAY EYE ICON) ---
              TextFormField(
                controller: _retypePasswordController,
                obscureText: _obscureRetypePass,
                decoration: InputDecoration(
                  labelText: "Retype New Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureRetypePass ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureRetypePass = !_obscureRetypePass;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please retype password.";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1), // PSU Blue
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CHANGE PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}