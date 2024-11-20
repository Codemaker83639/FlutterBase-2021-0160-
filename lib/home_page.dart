import 'package:firebase_auth/firebase_auth.dart'; // nuevo, corregido
import 'package:flutter/material.dart';           // nuevo
import 'package:provider/provider.dart';          // nuevo

import 'app_state.dart';                          // nuevo
import 'src/authentication.dart';                 // nuevo
import 'src/widgets.dart';
import 'guest_book.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Meetup'),
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/codelab.png'),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.calendar_today, 'October 30'),
          const IconAndDetail(Icons.location_city, 'San Francisco'),
          // Manejando estado de autenticación
          Consumer<ApplicationState>(
            builder: (context, appState, _) => AuthFunc(
              loggedIn: appState.loggedIn,
              signOut: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header("What we'll be doing"),
          const Paragraph(
            'Join us for a day full of Firebase Workshops and Pizza!',
          ),
          // Condicional para el inicio de sesión
          Consumer<ApplicationState>(
            builder: (context, appState, _) => appState.loggedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Header('Discussion'),
                      GuestBook(
                        addMessage: (message) =>
                            appState.addMessageToGuestBook(message),
                        messages: appState.guestBookMessages,
                      ),
                    ],
                  )
                : const SizedBox.shrink(), // Espacio vacío si no está logueado
          ),
        ],
      ),
    );
  }
}

