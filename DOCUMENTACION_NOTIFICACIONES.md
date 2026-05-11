# 📱 Automatización de Notificaciones Diarias - Betel App

Este documento explica la arquitectura, configuración y mantenimiento del sistema de notificaciones automáticas para el "Versículo del Día".

## 🎯 Objetivo
Automatizar el envío de un versículo bíblico diario a todos los usuarios de la aplicación sin incurrir en costos de servidores (Firebase Cloud Functions requiere el plan de pago "Blaze").

## 🚀 ¿Por qué GitHub Actions?
Se eligió GitHub Actions como "cerebro" del sistema porque:
1. **Es Gratuito**: Permite ejecutar scripts de forma programada sin costo.
2. **Independencia**: No dependemos de las limitaciones del plan gratuito de Firebase.
3. **Seguridad**: Permite manejar claves secretas (Tokens) de forma profesional.

---

## 🛠️ Configuración Necesaria (Secrets)

Para que el sistema funcione, debes tener configurados dos "Secrets" en tu repositorio de GitHub (**Settings > Secrets and variables > Actions**):

1. **`YV_TOKEN`**: Es el Token de Desarrollador de YouVersion. 
   - *Uso*: Permite que GitHub lea el versículo del día desde la API oficial de YouVersion.
2. **`FIREBASE_SERVICE_ACCOUNT`**: Es el archivo JSON de la "Cuenta de Servicio" de Firebase.
   - *Uso*: Da permiso a GitHub para enviar mensajes a través de Firebase Cloud Messaging (FCM).
   - *Cómo obtenerlo*: Consola de Firebase > Configuración del proyecto > Cuentas de servicio > Generar nueva clave privada.

---

## 📁 Archivos Creados

### 1. `.github/workflows/daily_verse.yml`
Es el archivo principal. Define **cuándo** y **cómo** se ejecuta la tarea.
- **Horario**: Está configurado para ejecutarse todos los días a las 7:00 AM (Caracas).
- **Lógica**: Contiene un script en **Node.js** que:
  1. Consulta la API de YouVersion para obtener el versículo.
  2. Limpia el texto (quita códigos HTML).
  3. Se conecta a Firebase y envía la notificación al tema (topic) llamado `diario`.

---

## ✍️ Cómo modificar la Notificación

Si deseas cambiar el diseño o el texto, debes editar el archivo `.github/workflows/daily_verse.yml` en las siguientes secciones:

### Cambiar el Título o el Texto
Busca el objeto `message` dentro del script de Node.js:
```javascript
notification: { 
  title: '✨ Dios te dice hoy:', // <--- Modifica el título aquí
  body: `"${text}" (${ref})`,  // <--- Modifica la estructura del cuerpo
  image: 'URL_DE_LA_IMAGEN'     // <--- Cambia el logo o imagen grande
}
```

### Cambiar el Color o Icono (Android)
```javascript
android: { 
  notification: { 
    color: '#D32F2F',          // <--- Cambia el color de la notificación
    icon: 'notification_icon'  // <--- Cambia el icono pequeño
  } 
}
```

---

## 🔄 Uso de Firebase
**Sí se usa Firebase**, pero solo como puente de mensajería (FCM). 
- **NO** usamos Cloud Functions.
- **NO** usamos el Plan Blaze.
- GitHub actúa como el "servidor" que le dice a Firebase: *"Oye, envía este mensaje a todos"*.

## ⏱️ Ejecución Manual
Si alguna vez quieres enviar la notificación manualmente (sin esperar a las 7:00 AM):
1. Ve a la pestaña **Actions** en tu GitHub.
2. Selecciona **"Daily Verse Push"** a la izquierda.
3. Haz clic en el botón gris **"Run workflow"**.

---

## ⏱️ Cuál es la limitación en los envios de mensajes?

Esta es la mejor parte de la arquitectura que hemos montado: prácticamente no tienes límites para una congregación, incluso si crece mucho.

Aquí tienes los detalles exactos:

1. Límites de Firebase (FCM)
Firebase Cloud Messaging en su plan gratuito (Spark) es extremadamente generoso:

Mensajes enviados: ¡Son ilimitados! Puedes enviar todos los mensajes que quieras al día o al mes.
Número de dispositivos: Puedes tener millones de usuarios registrados y Firebase les enviará el mensaje a todos sin cobrarte ni un centavo.
Temas (Topics): El sistema de "temas" (como el de diario que creamos) permite enviar mensajes masivos de forma muy eficiente.
2. Límites de GitHub Actions
GitHub también tiene límites, pero para este uso son insignificantes:

Minutos gratuitos: GitHub te regala 2,000 minutos al mes de ejecución en repositorios privados (y es ilimitado si tu repositorio es público).
Tu consumo: El script del versículo tarda apenas 30 segundos en ejecutarse.
Cálculo: 30 segundos x 30 días = 15 minutos al mes.


Conclusión: Estás usando apenas el 0.75% de tu regalo mensual de GitHub. Tienes "servidor" para rato.
¿Cuál es la única limitación real?
La única limitación de Firebase es la velocidad de envío (fan-out). Si llegaras a tener 10 millones de usuarios, la notificación podría tardar unos minutos en llegarle al último de la lista, pero para una iglesia, la llegada será prácticamente instantánea para todos.

En resumen: Puedes dormir tranquilo, este sistema es 100% gratuito y escalable para Betel App por muchos años.


*Documentación generada por Antigravity para Betel App - 2026*