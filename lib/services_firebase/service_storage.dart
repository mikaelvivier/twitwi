import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ServiceStorage {
  static final FirebaseStorage instance = FirebaseStorage.instance;
  Reference get ref => instance.ref();

  Future<String> addImage({
    required File file,
    required String folder,
    required String userId,
    required String imageName,
  }) async {
    final reference = ref.child(folder).child(userId).child(imageName);
    UploadTask task = reference.putFile(file);

    // Attendre la fin de le téléchargement
    TaskSnapshot snapshot = await task;

    // Obtenir l'URL de téléchargement de l'image
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl; // Retourner l'URL de l'image
  }
}