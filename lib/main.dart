import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';                      // a) Import firebase_core
import 'firebase_options.dart';                                        // b) Import options firebase
import 'pages/page_accueil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();                           // d) Attendre l'initialisation de l'application
  await Firebase.initializeApp(                                        // e) Initialiser la connexion à Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chti Face Bouc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const PageAccueil(title: "Cht'i Face Bouc"),
    );
  }
}
