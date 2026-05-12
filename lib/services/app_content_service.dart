import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/models/app_content_model.dart';

class AppContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collectionPath = 'app_content';
  static const String _docId = 'main_data';

  /// Obtiene el contenido actual de la app (Stream para actualizaciones en tiempo real)
  Stream<AppContentModel> getContentStream() {
    return _firestore.collection(_collectionPath).doc(_docId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppContentModel.fromMap(snapshot.data()!);
      }
      return AppContentModel.empty();
    });
  }

  /// Obtiene el contenido actual una sola vez
  Future<AppContentModel> getContent() async {
    final doc = await _firestore.collection(_collectionPath).doc(_docId).get();
    if (doc.exists && doc.data() != null) {
      return AppContentModel.fromMap(doc.data()!);
    }
    return AppContentModel.empty();
  }

  /// Actualiza los campos de texto
  Future<void> updateContent(AppContentModel content) async {
    await _firestore.collection(_collectionPath).doc(_docId).set(content.toMap(), SetOptions(merge: true));
  }

  /// Sube una imagen a Firebase Storage y devuelve la URL
  Future<String> uploadCarouselImage(File file) async {
    final fileName = 'carousel/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Agrega una URL de imagen a la lista del carrusel
  Future<void> addImageToCarousel(String imageUrl) async {
    await _firestore.collection(_collectionPath).doc(_docId).set({
      'carouselImages': FieldValue.arrayUnion([imageUrl]),
    }, SetOptions(merge: true));
  }

  /// Elimina una URL de imagen de la lista del carrusel
  Future<void> removeImageFromCarousel(String imageUrl) async {
    await _firestore.collection(_collectionPath).doc(_docId).set({
      'carouselImages': FieldValue.arrayRemove([imageUrl]),
    }, SetOptions(merge: true));
    
    // Opcional: Eliminar del storage si la URL pertenece a nuestro bucket
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('No se pudo eliminar del storage: $e');
    }
  }
}
