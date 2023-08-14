import 'package:flutter/material.dart';
import 'package:p001/services/auth/auth_service.dart';
import 'package:p001/view/invatory/invatory_view.dart';
import 'package:p001/view/invatory/new_invatory_view.dart';
import 'package:p001/view/login_view.dart';


import 'package:p001/view/register_view.dart';
import 'package:p001/view/verify_email_view.dart';
import 'dart:developer' as devtools show log;
import 'package:p001/constants/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primarySwatch: Colors.blue),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      // notesRoute: (context) => const NotesView(),
      verifyRote: (context) => const VerifyEmailView(),
      invatoryRote: (context) => const InvatoryView(),
      NewInvatoryViewRote: (context) => const NewInvatoryView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              devtools.log(user.toString());
              if (user != null) {
                if (user.isEmailVerified) {
                  return const InvatoryView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }

            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
