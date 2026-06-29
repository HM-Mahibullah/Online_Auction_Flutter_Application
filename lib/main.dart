import 'package:antique/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    runApp(const MyApp());
  } catch (e) {
    // If Firebase fails, show setup instructions
    runApp(const FirebaseSetupApp());
  }
}

// Temporary app to show when Firebase is not configured
class FirebaseSetupApp extends StatelessWidget {
  const FirebaseSetupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color: Color(0xFFB8860B),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Firebase Not Configured',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'To run this app, you need to set up Firebase:',
                  style: TextStyle(fontSize: 16, color: Color(0xFF5D4037)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 Quick Setup Steps:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      SizedBox(height: 12),
                      SetupStep(
                        number: '1',
                        text: 'Go to console.firebase.google.com',
                      ),
                      SetupStep(
                        number: '2',
                        text: 'Create a new Firebase project',
                      ),
                      SetupStep(
                        number: '3',
                        text: 'Add Android app with package:\ncom.example.antique',
                      ),
                      SetupStep(
                        number: '4',
                        text: 'Download google-services.json',
                      ),
                      SetupStep(
                        number: '5',
                        text: 'Place it in: android/app/',
                      ),
                      SetupStep(
                        number: '6',
                        text: 'Enable Authentication & Firestore',
                      ),
                      SetupStep(
                        number: '7',
                        text: 'Restart the app',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '📚 See QUICKSTART.md for detailed instructions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SetupStep extends StatelessWidget {
  final String number;
  final String text;

  const SetupStep({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFB8860B),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D4037),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
