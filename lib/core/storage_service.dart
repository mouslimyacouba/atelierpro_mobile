import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Centralise l'upload de photos vers Firebase Storage.
class StorageService {
  static final _storage = FirebaseStorage.instance;
  static final _picker = ImagePicker();

  /// Ouvre le sélecteur d'image (galerie), compresse légèrement, et retourne
  /// le fichier choisi. Retourne null si l'utilisateur annule.
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  /// Upload un fichier vers Firebase Storage et retourne son URL de téléchargement.
  static Future<String> upload({
    required String bucket,
    required String userId,
    required String key,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final path = '$bucket/$userId/$key.$ext';

    final ref = _storage.ref().child(path);
    await ref.putFile(file);

    final downloadUrl = await ref.getDownloadURL();
    return '$downloadUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }
}
