import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUser {
  final String uid;
  final String username;
  final String email;
  final String name;
  final String? mobile;

  const AuthUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.name,
    this.mobile,
  });

  factory AuthUser.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return AuthUser(
      uid: document.id,
      username: data['username'],
      email: data['email'],
      name: data['name'],
      mobile: data['mobile'],
    );
  }

  static Future<AuthUser?> fromUid(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    return AuthUser.fromSnapshot(doc[0]);
  }
}
