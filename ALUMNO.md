# 🎓 Manual del Rol: Alumno

Este documento describe las funcionalidades y responsabilidades de los usuarios con el rol de Alumno en la aplicación Betel.

## 🌟 ¿Qué puede hacer un Alumno?

### 1. Ver sus Clases
- Acceder a una lista personalizada de las materias o cursos en los que está inscrito.
- Ver el progreso general de su formación espiritual y académica.

### 2. Estudiar Contenidos
- Entrar al detalle de cada sección de una clase.
- Leer materiales, ver lecciones y prepararse para las evaluaciones.

### 3. Realizar Exámenes
- Tomar evaluaciones diseñadas por los maestros.
- Recibir retroalimentación sobre sus conocimientos.

## 🛠️ ¿Qué archivos definen este rol?
- `lib/presentation/screens/student/student_main_screen.dart`: Panel principal del alumno.
- `lib/presentation/screens/student/student_classes_screen.dart`: Listado de materias.
- `lib/presentation/screens/student/take_exam_screen.dart`: Interfaz para rendir pruebas.

## 💡 ¿Cómo funciona?
El sistema identifica al usuario mediante su cuenta de acceso y filtra automáticamente la base de datos para mostrarle ÚNICAMENTE las clases y exámenes que le corresponden a su nivel o grupo.
