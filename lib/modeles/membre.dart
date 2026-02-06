// membre.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constantes.dart';

class Membre {
  DocumentReference reference; // Référence au document Firestore
  String id; // Identifiant unique de l'utilisateur
  Map<String, dynamic> map; // Dictionnaire contenant les données de l'utilisateur

  Membre({
    required this.reference, 
    required this.id, 
    required this.map,
  });

  String get name => map[nameKey] ?? ''; // Getter pour le nom
  String get surname => map[surnameKey] ?? ''; // Getter pour le prénom
  String get profilePicture => map[profilePictureKey] ?? ''; // Getter pour la photo de profil
  String get coverPicture => map[coverPictureKey] ?? ''; // Getter pour la photo de couverture
  String get description => map[descriptionKey] ?? ''; // Getter pour la description

  // Getter pour le nom complet
  String get fullName => '$surname $name';

  // Méthode pour convertir l'objet Membre en Map pour la sauvegarde dans Firestore
  Map<String, dynamic> toMap() {
    return {
      memberIdKey: id,
      nameKey: name,
      surnameKey: surname,
      profilePictureKey: profilePicture,
      coverPictureKey: coverPicture,
      descriptionKey: description,
    };
  }

  // Méthode pour créer un membre à partir d'un DocumentSnapshot
  factory Membre.fromSnapshot(DocumentSnapshot snapshot) {
    return Membre(
      reference: snapshot.reference,
      id: snapshot.id,
      map: snapshot.data() as Map<String, dynamic>,
    );
  }
}