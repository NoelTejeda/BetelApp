import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Solicitar permisos (especialmente en iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
      
      // 2. Suscribirse al tema de versículos diarios
      await _messaging.subscribeToTopic('daily_verse');
      
      // 3. Obtener el token (opcional, por si quieres enviar a usuarios específicos)
      // String? token = await _messaging.getToken();
      // print("FCM Token: $token");
    }

    // 4. Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: ${message.notification}');
        }
        // Aquí podrías mostrar un snackbar o una notificación local personalizada
      }
    });

    // 5. Manejar clicks en notificaciones cuando la app está en segundo plano o cerrada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notification clicked!');
      }
      // Navegar a la pantalla de versículos
    });
  }

  // Este método debe ser una función global o estática para background handling
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Si necesitas procesar algo en segundo plano
    if (kDebugMode) {
      print("Handling a background message: ${message.messageId}");
    }
  }
}
