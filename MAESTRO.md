# 👨‍🏫 Manual del Rol: Maestro

Este documento describe las funcionalidades y herramientas disponibles para los usuarios con el rol de Maestro en la aplicación Betel.

## 🌟 ¿Qué puede hacer un Maestro?

### 1. Gestión de Clases
- Ver el listado de las clases que tiene asignadas para impartir.
- Monitorear el progreso de los alumnos inscritos en sus materias.

### 2. Editor de Exámenes
- Crear nuevas evaluaciones para sus alumnos.
- Editar preguntas, opciones y configurar los criterios de aprobación.

### 3. Control de Contenidos
- Revisar el detalle de las lecciones y secciones para asegurar que la enseñanza sea la correcta.

## 🛠️ ¿Qué archivos definen este rol?
- `lib/presentation/screens/teacher/teacher_main_screen.dart`: Panel de control del maestro.
- `lib/presentation/screens/teacher/teacher_classes_screen.dart`: Gestión de materias asignadas.
- `lib/presentation/screens/teacher/exam_editor_screen.dart`: Herramienta para crear evaluaciones.

## 💡 ¿Cómo funciona?
El maestro tiene privilegios de "Escritura" en la sección educativa. Esto significa que sus cambios impactan directamente en lo que los alumnos ven. El editor de exámenes utiliza un sistema de formularios dinámicos para facilitar la creación de pruebas sin saber programar.
