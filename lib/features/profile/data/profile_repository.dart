import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

class ProfileRepository {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  Future<String?> uploadAvatar(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final ref = _storage.ref().child('profiles').child(user.uid).child('avatar.jpg');
      
      // Завантажуємо файл
      final uploadTask = await ref.putFile(imageFile);
      
      // Повертаємо URL
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Помилка завантаження фото: $e');
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePhotoURL(photoUrl);
      await user.reload();
    }
  }
}