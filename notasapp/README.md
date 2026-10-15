# 📝 Notas App (Android, iOS & Firebase)

Una aplicación móvil multiplataforma desarrollada en **Flutter** para **Android** e **iOS**, diseñada para crear, gestionar y personalizar notas y checklists en la nube, con autenticación de usuarios (**Firebase Authentication**) y sincronización en tiempo real (**Cloud Firestore**).

---

## ✨ Características Principales

### 1. 🔐 Autenticación y Separación Estricta de Usuarios
- **Sistema de Login y Registro**:
  - Pantalla móvil optimizada para iniciar sesión y registrar nuevas cuentas con correo electrónico y contraseña.
  - Validación de campos en tiempo real y mensajes claros en español.
  - **Aislamiento total de datos**: cada usuario cuenta con su propia colección en Firestore (`users/{userId}/notes/{noteId}`). El Usuario A nunca puede ver ni modificar las notas del Usuario B.
  - **Cierre de sesión seguro**: menú desplegable en el avatar del usuario con confirmación.
  - **Modo Demo / Sin conexión**: permite probar y utilizar la aplicación de forma inmediata incluso sin internet o antes de vincular credenciales de producción.

### 2. ☁️ Sincronización en la Nube con Cloud Firestore
- Guardado y actualización en la nube en tiempo real.
- Soporte para trabajo offline y persistencia local (`SharedPreferences`).

### 3. 📝 Gestión Completa de Notas y Checklists
- **Títulos destacados** y **área de escritura libre**.
- **Listas de tareas (checklists)** con casillas de verificación interactivas, edición en línea, progreso completado (ej. *3 de 5*) y creación rápida de tareas presionando *Enter*.
- **Paleta de 10 colores personalizables**: cambio de color directamente desde la tarjeta en la pantalla principal o desde el editor en tiempo real.
- **Acciones rápidas**: fijar notas importantes al principio, eliminarlas con confirmación y botón instantáneo de **Deshacer (Undo)**.

### 4. 📱 Experiencia Móvil Optimizada para Celulares
- Diseño responsivo adaptado para pantallas de smartphones (Android e iOS).
- Manejo inteligente del teclado virtual (`SingleChildScrollView` + `SafeArea` para evitar desbordamientos).
- Vistas alternables entre cuadrícula escalonada (*staggered masonry*) y lista de una sola columna.
- Buscador integrado (títulos, texto y tareas) y barra de filtros por color.

---

## 🚀 Configuración de Firebase

La aplicación está lista para conectarse a tu proyecto de Firebase. Puedes configurarlo de dos maneras:

### Opción 1: Automática con FlutterFire CLI (Recomendado)
1. Instala el CLI de Firebase si aún no lo tienes:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
2. Activa FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Ejecuta la configuración en la raíz del proyecto:
   ```bash
   flutterfire configure
   ```
   *Esto actualizará automáticamente [`lib/firebase_options.dart`](file:///c:/Users/Leandro/Desktop/NotasAPP/notasapp/lib/firebase_options.dart) con las claves reales de tu proyecto de Firebase.*

### Opción 2: Manual mediante Firebase Console
1. Entra a [Firebase Console](https://console.firebase.google.com/) y crea un proyecto.
2. Habilita **Authentication** -> Método de inicio de sesión: **Correo electrónico/contraseña**.
3. Habilita **Cloud Firestore Database** (en modo de prueba o producción).
4. Abre [`lib/firebase_options.dart`](file:///c:/Users/Leandro/Desktop/NotasAPP/notasapp/lib/firebase_options.dart) y coloca tus claves (`apiKey`, `appId`, `projectId`, etc.).

---

## 📲 Cómo Ejecutar la Aplicación

- **En Android (celular físico o emulador)**:
  ```bash
  flutter run
  ```
- **En iOS (desde macOS con simulador o iPhone conectado)**:
  ```bash
  flutter run -d ios
  ```
- **Prueba rápida en Navegador o Windows**:
  ```bash
  flutter run -d edge
  ```

---

## 🧪 Pruebas Automatizadas

Para ejecutar las pruebas que validan la separación de notas por usuario, autenticación y operaciones CRUD:
```bash
flutter test
```
Para verificar la calidad y reglas de lint del código:
```bash
flutter analyze
```

---

## 📂 Estructura del Código

```
lib/
├── constants/
│   └── app_colors.dart             # Paleta de 10 colores y contrastes adaptativos
├── controllers/
│   ├── auth_controller.dart        # Gestión de sesión, login, registro y usuario activo
│   └── notes_controller.dart       # Gestión de notas del usuario, filtros y sincronización
├── models/
│   ├── checklist_item.dart         # Modelo de ítems de checklist
│   ├── note_model.dart             # Modelo de la nota (título, contenido, color, tareas)
│   └── user_model.dart             # Modelo de usuario autenticado
├── services/
│   ├── auth_service.dart           # Servicio de Firebase Authentication y fallback local
│   └── firestore_notes_service.dart# Sincronización en Cloud Firestore por usuario (users/{uid}/notes)
├── views/
│   ├── auth/
│   │   └── login_screen.dart       # Pantalla de Login y Registro optimizada para celulares
│   ├── home_screen.dart            # Pantalla principal con notas, menú de usuario y filtros
│   ├── note_editor_screen.dart     # Editor de contenido, checklist y color en tiempo real
│   └── widgets/
│       ├── checklist_editor.dart   # Editor interactivo de checklists con barra de progreso
│       ├── color_picker_sheet.dart # Modal inferior para seleccionar color
│       └── note_card.dart          # Tarjeta de nota con previsualización y acciones rápidas
├── firebase_options.dart           # Opciones de inicialización multiplataforma de Firebase
└── main.dart                       # Punto de entrada con temas y enrutamiento por autenticación
```
