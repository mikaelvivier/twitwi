import 'package:flutter/material.dart';
import '../services_firebase/service_authentification.dart';

class PageAuthentification extends StatefulWidget {
  const PageAuthentification({super.key});

  @override
  State<PageAuthentification> createState() => _PageAuthentificationState();
}

class _PageAuthentificationState extends State<PageAuthentification> {
  bool accountExists = true;

  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final surnameController = TextEditingController();
  final nameController = TextEditingController();

  final auth = ServiceAuthentification();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    surnameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _onSelectedChanged(Set<bool> newValue) {
    setState(() {
      accountExists = newValue.first;
    });
  }

  void _handleHauth() async {
    String message = "";
    if (accountExists) {
      message = await auth.signIn(
        email: mailController.text,
        password: passwordController.text,
      );
    } else {
      message = await auth.createAccount(
        email: mailController.text,
        password: passwordController.text,
        surname: surnameController.text,
        name: nameController.text,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cht'i Face Bouc")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/logo.png'), // Remplace par ton image
              const SizedBox(height: 20),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: true, label: Text("Déjà un compte")),
                  ButtonSegment<bool>(value: false, label: Text("S'inscrire")),
                ],
                selected: {accountExists},
                onSelectionChanged: _onSelectedChanged,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: mailController,
                        decoration: const InputDecoration(labelText: "Adresse mail"),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Mot de passe"),
                      ),
                      if (!accountExists) ...[
                        TextField(
                          controller: surnameController,
                          decoration: const InputDecoration(labelText: "Prénom"),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: "Nom"),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleHauth,
                        child: const Text("Connexion"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
