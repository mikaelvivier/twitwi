import 'package:cloud_firestore/cloud_firestore.dart';
import 'constantes.dart';

class Post {
  DocumentReference reference;
  String id;
  Map<String, dynamic> map;

  Post({
    required this.reference,
    required this.id,
    required this.map,
  });

  String get memberId => map[memberIdKey] ?? '';
  String get text => map[textKey] ?? '';
  String get image => map[postImageKey] ?? '';
  Timestamp get date {
    final dateValue = map[dateKey];
    if (dateValue is Timestamp) {
      return dateValue;
    } else if (dateValue is int) {
      // Convertir les millisecondes en Timestamp
      return Timestamp.fromMillisecondsSinceEpoch(dateValue);
    }
    return Timestamp.now();
  }
  List<dynamic> get likes => map[likesKey] ?? [];

  int get likesCount => likes.length;

  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  Map<String, dynamic> toMap() {
    return {
      memberIdKey: memberId,
      textKey: text,
      postImageKey: image,
      dateKey: date,
      likesKey: likes,
    };
  }

  factory Post.fromSnapshot(DocumentSnapshot snapshot) {
    return Post(
      reference: snapshot.reference,
      id: snapshot.id,
      map: snapshot.data() as Map<String, dynamic>,
    );
  }
}
