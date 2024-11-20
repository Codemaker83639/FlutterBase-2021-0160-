import 'dart:async'; // Import necesario para StreamSubscription

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'guest_book_message.dart'; // Import necesario para manejar mensajes

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  // Manejo de mensajes del guestbook
  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        // Suscribirse a cambios en la colección 'guestbook'
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (final document in snapshot.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String,
              ),
            );
          }
          notifyListeners(); // Notificar a los widgets para actualizar la UI
        });
      } else {
        _loggedIn = false;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel(); // Cancelar la suscripción al cerrar sesión
      }
      notifyListeners();
    });
  }

  // Método para agregar un mensaje al guestbook
  Future<DocumentReference> addMessageToGuestBook(String message) async {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance.collection('guestbook').add({
      'text': message, // El mensaje que el usuario ha dejado
      'timestamp': DateTime.now().millisecondsSinceEpoch, // Marca de tiempo
      'name': FirebaseAuth.instance.currentUser!.displayName, // Nombre del usuario
      'userId': FirebaseAuth.instance.currentUser!.uid, // ID del usuario
    });
  }
}
