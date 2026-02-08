import 'package:cloud_firestore/cloud_firestore.dart';
import 'constantes.dart';

class Comment {
  DocumentReference reference;
  String id;
  Map<String, dynamic> map;

  Comment({
    required this.reference,
    required this.id,
    required this.map,
  });

  String get postId => map[postIdKey] ?? '';
  String get memberId => map[commentMemberIdKey] ?? '';
  String get text => map[commentTextKey] ?? '';
  Timestamp get date {
    final dateValue = map[commentDateKey];
    if (dateValue is Timestamp) {
      return dateValue;
    } else if (dateValue is int) {
      return Timestamp.fromMillisecondsSinceEpoch(dateValue);
    }
    return Timestamp.now();
  }

  Map<String, dynamic> toMap() {
    return {
      postIdKey: postId,
      commentMemberIdKey: memberId,
      commentTextKey: text,
      commentDateKey: date,
    };
  }

  factory Comment.fromSnapshot(DocumentSnapshot snapshot) {
    return Comment(
      reference: snapshot.reference,
      id: snapshot.id,
      map: snapshot.data() as Map<String, dynamic>,
    );
  }
}
