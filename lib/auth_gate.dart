import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'home.dart';
import 'main.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              //GoogleProvider(clientId: "1018227793260-1gp886c0727egreurfolh8i8gnfg8okt.apps.googleusercontent.com"),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/userLogin.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? Text('Welcome back, please sign in!', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))
                    : Text('Welcome to Expense Tracker, please sign up!', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        }

        return const HomeScreen();
      },
    );
  }
}