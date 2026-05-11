const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Función HTTPS que recibe los datos del versículo desde GitHub Actions.
 * Esto permite usar el Plan Spark (Gratis) delegando la petición externa a GitHub.
 */
exports.triggerDailyVerse = functions.https.onRequest(async (req, res) => {
  // Validación de seguridad básica
  // IMPORTANTE: Esta clave debe coincidir con la que pongas en GitHub Secrets (CF_API_KEY)
  const authKey = req.headers['x-api-key'];
  const SECRET_KEY = "BetelApp2026SecretKey"; // <--- PUEDES CAMBIAR ESTA CLAVE

  if (authKey !== SECRET_KEY) {
    return res.status(403).send('No autorizado');
  }

  const { text, reference, passageId } = req.body;

  if (!text || !reference) {
    return res.status(400).send('Faltan datos del versículo');
  }

  try {
    // 1. Guardar en Firestore para que la app lo muestre al abrirse
    await admin.firestore().collection('metadata').doc('versiculo_del_dia').set({
      text,
      reference,
      passageId,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // 2. Enviar Notificación Push de Alta Prioridad al tema "diario"
    const message = {
      notification: {
        title: '📖 Versículo del Día',
        body: `${text} - ${reference}`
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'daily_verse_channel',
          priority: 'max',
          sound: 'default'
        }
      },
      apns: {
        payload: {
          aps: { 
            contentAvailable: true,
            sound: 'default'
          }
        }
      },
      topic: 'diario' 
    };

    await admin.messaging().send(message);
    
    console.log('✅ Versículo procesado y notificación enviada:', reference);
    return res.status(200).send('Éxito');
  } catch (error) {
    console.error('❌ Error:', error);
    return res.status(500).send(error.toString());
  }
});
