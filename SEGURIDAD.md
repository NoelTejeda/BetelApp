# 🛡️ Manual del Rol: Seguridad / Administrador

Este documento describe las responsabilidades y herramientas críticas de los usuarios con rol de Seguridad o Administrador en la aplicación Betel.

## 🌟 ¿Qué puede hacer un Administrador de Seguridad?

### 1. Gestión de Usuarios
- Crear cuentas para nuevos miembros de la congregación.
- Editar información de perfiles existentes.
- Suspender o eliminar accesos si es necesario.

### 2. Asignación de Roles
- Determinar quién es **Alumno**, quién es **Maestro** y quién tiene rango de **Seguridad**.
- Esta es la función más importante, ya que define qué puede ver y hacer cada persona en la app.

### 3. Supervisión de Integridad
- Asegurar que la base de datos de usuarios esté actualizada y sea veraz.

## 🛠️ ¿Qué archivos definen este rol?
- `lib/presentation/screens/admin/user_management_screen.dart`: La herramienta central de gestión de personas y permisos.

## 💡 ¿Cómo funciona?
Este rol tiene acceso a los niveles más altos de la base de datos (Firebase). Cuando el usuario de Seguridad cambia un rol, la aplicación actualiza instantáneamente los permisos del usuario afectado, obligando a la app a mostrar las nuevas funciones correspondientes.

> [!CAUTION]
> Este rol tiene acceso a información sensible. Las acciones realizadas aquí son definitivas para el acceso a la plataforma.
