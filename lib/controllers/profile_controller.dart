import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Lấy dữ liệu user từ Firestore + Auth
  Future<Map<String, dynamic>?> getUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật hồ sơ
  Future<void> updateProfile({
    required String displayName,
    required String photoUrl,
    required String phone,
  }) async {
    final user = currentUser;
    if (user == null) return;

    // Update Firebase Auth
    if (displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }

    if (photoUrl.isNotEmpty) {
      await user.updatePhotoURL(photoUrl);
    }

    // Update Firestore
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await user.reload();
  }
}
