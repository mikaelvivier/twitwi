import 'package:firebase_auth/firebase_auth.dart';
import 'service_firestore.dart'; // Assurez-vous d'importer le bon chemin vers votre ServiceFirestore

class ServiceAuthentification {
  // Récupérer une instance de auth
  final instance = FirebaseAuth.instance;
  final ServiceFirestore firestoreService = ServiceFirestore(); // Ajout de l'instance de ServiceFirestore

  // Connecter à Firebase
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    String result = "";
    try {
      await instance.signInWithEmailAndPassword(email: email, password: password);
      result = "Connexion réussie";
    } on FirebaseAuthException catch (e) {
      result = "Erreur de connexion : ${e.message}";
    }
    return result;
  }

  // Créer un compte sur Firebase
  Future<String> createAccount({
    required String email,
    required String password,
    required String surname,
    required String name,
  }) async {
    String result = "";
    try {
      // Crée un nouvel utilisateur avec son email et mot de passe
      UserCredential userCredential = await instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer l'UID de l'utilisateur nouvellement créé
      String uid = userCredential.user?.uid ?? "";

      // Préparer les données du membre à ajouter à Firestore
      Map<String, dynamic> memberData = {
        'email': email,
        'surname': surname,
        'name': name,
      };

      // Appeler la méthode addMember pour ajouter le membre dans Firestore
      await firestoreService.addMember(id: uid, data: memberData);

      result = "Compte créé avec succès";
    } on FirebaseAuthException catch (e) {
      result = "Erreur de création de compte : ${e.message}";
    }
    return result;
  }

  // Déconnecter de Firebase
  Future<bool> signOut() async {
    bool result = false;
    try {
      await instance.signOut();
      result = true;
    } catch (e) {
      result = false;
    }
    return result;
  }

  // Récupérer l'uid unique de l'utilisateur
  String? get myId => instance.currentUser?.uid;

  // Voir si vous êtes l'utilisateur
  bool isMe(String profileId) {
    bool result = false;
    final currentUser = instance.currentUser;
    if (currentUser != null && currentUser.uid == profileId) {
      result = true;
    }
    return result;
  }
}