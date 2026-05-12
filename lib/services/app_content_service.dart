import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/models/app_content_model.dart';
import '../domain/models/commission_model.dart';

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
    
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('No se pudo eliminar del storage: $e');
    }
  }

  /// Actualiza una comisión específica en la lista manteniendo el orden
  Future<void> updateCommission(int index, CommissionModel updatedCommission) async {
    final currentContent = await getContent();
    
    // Si la lista en Firebase está vacía o es más corta que el índice que queremos editar,
    // la inicializamos con los valores por defecto para mantener el orden.
    List<CommissionModel> newList;
    if (currentContent.commissions.isEmpty) {
      newList = List.from(AppContentModel.defaultCommissions);
    } else {
      newList = List.from(currentContent.commissions);
      // Si por alguna razón la lista es más corta que el índice (ej. se borraron comisiones),
      // rellenamos con las originales hasta llegar al índice.
      while (newList.length <= index) {
        newList.add(AppContentModel.defaultCommissions[newList.length]);
      }
    }
    
    // Actualizamos el elemento en la posición exacta
    newList[index] = updatedCommission;

    await _firestore.collection(_collectionPath).doc(_docId).set({
      'commissionsList': newList.map((c) => c.toMap()).toList(),
    }, SetOptions(merge: true));
  }
}
