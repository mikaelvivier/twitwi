import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeles/constantes.dart'; // Assurez-vous d'importer le bon chemin
import 'service_storage.dart';

class ServiceFirestore {
  // Accès à la BDD
  static final instance = FirebaseFirestore.instance;

  // Accès spécifique à la collection
  final CollectionReference firestoreMember = instance.collection(memberCollectionKey);

  // Ajouter un membre
  addMember({
    required String id,
    required Map<String, dynamic> data,
  }) {
    firestoreMember.doc(id).set(data);
  }

  // Mettre à jour un membre
  updateMember({
    required String id,
    required Map<String, dynamic> data,
  }) {
    firestoreMember.doc(id).update(data);
  }

  // Stockage et mise à jour d'une image
  updateImage({
    required File file,
    required String folder,
    required String memberId,
    required String imageName,
  }) {
    ServiceStorage()
    .addImage(
      file: file,
      folder: folder,
      userId: memberId,
      imageName: imageName,
    ).then((imageUrl) {
      updateMember(id: memberId, data: {'imageName': imageUrl});
    });
  }
}