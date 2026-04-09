import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String intakeDisplay = "0";
  
  // Reference sa Realtime Database
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://h2o-project-e83d9-default-rtdb.firebaseio.com',
  ).ref();

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    // 1. Kunin ang UID ng kasalukuyang user
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      // 2. Palitan ang 'student01' ng $uid para dynamic ang pagbabasa
      _dbRef.child('users/$uid/intake').onValue.listen((event) {
        if (mounted) {
          setState(() {
            // Siguraduhing hindi null ang value para hindi mag-error ang app
            intakeDisplay = event.snapshot.value?.toString() ?? "0";
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("H2O Dashboard"),
        backgroundColor: Colors.blue[900], // Ginawa nating Blue para sa PSU theme
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("Current Water Intake:", style: TextStyle(fontSize: 18)),
            Text(
              "$intakeDisplay ml", 
              style: const TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold, 
                color: Colors.blue
              )
            ),
          ],
        ),
      ),
    );
  }
}