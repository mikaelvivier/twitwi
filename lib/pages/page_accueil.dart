import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({super.key, required this.title});
  final String title;

  @override
  State<PageAccueil> createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          return Center(
            child: snapshot.hasData
                ? const Text("Connecté")
                : const Text("Non connecté"),
          );
        },
      ),
    );
  }
}
