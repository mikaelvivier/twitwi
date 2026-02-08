import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeles/constantes.dart';
import 'service_storage.dart';

class ServiceFirestore {
  // Accès à la BDD
  static final instance = FirebaseFirestore.instance;

  // Accès spécifique aux collections
  final CollectionReference firestoreMember = instance.collection(memberCollectionKey);
  final CollectionReference firestorePost = instance.collection(postCollectionKey);

  // ========== MEMBRES ==========
  
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

  // Récupérer un membre par son ID
  Future<DocumentSnapshot> getMember(String memberId) {
    return firestoreMember.doc(memberId).get();
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

  // ========== POSTS ==========
  
  // Ajouter un post
  Future<void> addPost({
    required String memberId,
    required String text,
    String image = '',
  }) {
    return firestorePost.add({
      memberIdKey: memberId,
      textKey: text,
      postImageKey: image,
      dateKey: Timestamp.now(),
      likesKey: [],
    });
  }

  // Récupérer tous les posts (triés par date décroissante)
  Stream<QuerySnapshot> getPosts() {
    return firestorePost.orderBy(dateKey, descending: true).snapshots();
  }

  // Supprimer un post
  Future<void> deletePost(String postId) {
    return firestorePost.doc(postId).delete();
  }

  // Toggle like sur un post
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    DocumentSnapshot postDoc = await firestorePost.doc(postId).get();
    List<dynamic> likes = postDoc.get(likesKey) ?? [];
    
    if (likes.contains(userId)) {
      // Retirer le like
      likes.remove(userId);
    } else {
      // Ajouter le like
      likes.add(userId);
    }
    
    return firestorePost.doc(postId).update({likesKey: likes});
  }

  // ========== COMMENTAIRES ==========
  
  // Ajouter un commentaire
  Future<void> addComment({
    required String postId,
    required String memberId,
    required String text,
  }) {
    return instance.collection(commentCollectionKey).add({
      postIdKey: postId,
      commentMemberIdKey: memberId,
      commentTextKey: text,
      commentDateKey: Timestamp.now(),
    });
  }

  // Récupérer les commentaires d'un post
  Stream<QuerySnapshot> getComments(String postId) {
    return instance
        .collection(commentCollectionKey)
        .where(postIdKey, isEqualTo: postId)
        .orderBy(commentDateKey, descending: false)
        .snapshots();
  }

  // Compter les commentaires d'un post
  Future<int> getCommentsCount(String postId) async {
    final snapshot = await instance
        .collection(commentCollectionKey)
        .where(postIdKey, isEqualTo: postId)
        .get();
    return snapshot.docs.length;
  }
}