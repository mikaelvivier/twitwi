import 'package:flutter/material.dart';
import '../services_firebase/service_authentification.dart';
import '../modeles/app_theme.dart';

class PageAuthentification extends StatefulWidget {
  const PageAuthentification({super.key});

  @override
  State<PageAuthentification> createState() => _PageAuthentificationState();
}

class _PageAuthentificationState extends State<PageAuthentification> with SingleTickerProviderStateMixin {
  bool accountExists = true;

  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  final surnameController = TextEditingController();
  final nameController = TextEditingController();

  final auth = ServiceAuthentification();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    surnameController.dispose();
    nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSelectedChanged(Set<bool> newValue) {
    setState(() {
      accountExists = newValue.first;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _handleAuth() async {
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.people,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    "Cht'i Face Bouc",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Connectez-vous avec vos amis",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Toggle between login/signup
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text("Connexion"),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text("S'inscrire"),
                        ),
                      ],
                      selected: {accountExists},
                      onSelectionChanged: _onSelectedChanged,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                          return Colors.transparent;
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return AppTheme.primaryStart;
                          }
                          return Colors.white;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Form Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: AppTheme.glassCardDecoration(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: mailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Adresse email",
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Mot de passe",
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          if (!accountExists) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: surnameController,
                              decoration: const InputDecoration(
                                labelText: "Prénom",
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Nom",
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          
                          // Submit Button with gradient
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Container(
                              decoration: AppTheme.gradientButtonDecoration(
                                gradient: AppTheme.accentGradient,
                              ),
                              child: ElevatedButton(
                                onPressed: _handleAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  accountExists ? "Se connecter" : "Créer un compte",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
