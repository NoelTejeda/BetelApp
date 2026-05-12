import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../domain/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential userCredential;
      try {
        // Intentar iniciar sesión
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Registrar evento en Analytics
        await FirebaseAnalytics.instance.logLogin(loginMethod: 'email');
      } on FirebaseAuthException catch (e) {
        print('Código de error Firebase: ${e.code}');
        // Si el usuario no existe y es nuestro usuario de prueba, lo creamos
        if ((e.code == 'user-not-found' || e.code == 'invalid-credential') && email == 'noelati@gmail.com') {
          print('Creando cuenta de admin para pruebas...');
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          // Guardar su rol y datos en Firestore
          final newUser = UserModel(
            id: userCredential.user!.uid,
            name: 'noel',
            email: email,
            role: UserRole.admin,
          );
          await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());
          return newUser;
        } else if (email == 'seguridad@betel.app') {
          // Si es el de seguridad y falló el login, intentamos crearlo
          // Si falla al crear porque ya existe, es que simplemente la clave está mal
          try {
            print('Intentando crear cuenta de seguridad...');
            userCredential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            
            final newUser = UserModel(
              id: userCredential.user!.uid,
              name: 'Encargado Seguridad',
              email: email,
              role: UserRole.seguridad,
            );
            await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());
            return newUser;
          } catch (signUpError) {
            print('Error al intentar auto-registrar seguridad: $signUpError');
            rethrow; // Re-lanzamos el error original de login
          }
        } else {
          rethrow;
        }
      }

      // Si inició sesión correctamente, obtener su rol y estado desde Firestore
      final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data()!, doc.id);
        
        // Verificar si el usuario está activo
        if (!user.isActive) {
          await _auth.signOut();
          throw '🚫 Tu acceso ha sido restringido. Contacta a seguridad.';
        }
        
        return user;
      } else {
        // Fallback si por alguna razón no tiene documento en Firestore
        return UserModel(
          id: userCredential.user!.uid,
          name: email.split('@')[0],
          email: email,
          role: UserRole.alumno,
          isActive: true,
        );
      }
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  /// Obtiene todos los usuarios de la comunidad (Para el rol Seguridad)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error en getAllUsers: $e');
      rethrow;
    }
  }

  /// Actualiza los datos de un usuario (Nombre, Rol, etc.)
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error en updateUser: $e');
      rethrow;
    }
  }

  /// Cambia el estado de acceso de un usuario
  Future<void> toggleUserStatus(String userId, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': !currentStatus,
      });
    } catch (e) {
      print('Error en toggleUserStatus: $e');
      rethrow;
    }
  }

  // Método para que el encargado de seguridad cree otros usuarios sin perder su sesión
  Future<void> registerUserByAdmin({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // 1. Crear una instancia secundaria de Firebase para no cerrar la sesión actual
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      // 2. Crear el usuario en Firebase Auth usando la app secundaria
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      // 3. Guardar el perfil en Firestore (usando la instancia principal)
      final newUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: role,
        isActive: true,
      );
      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

      print('✅ Usuario ${email} creado correctamente.');
    } catch (e) {
      print('❌ Error en registerUserByAdmin: $e');
      rethrow;
    } finally {
      // 4. Limpiar la app secundaria
      await secondaryApp?.delete();
    }
  }

  /// Obtiene los datos del usuario actual autenticado
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
