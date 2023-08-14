import 'package:flutter/material.dart';
import 'package:p001/Utilites/show_error.dart';
import 'package:p001/constants/router.dart';
import 'package:p001/services/auth/auth_exceptions.dart';
import 'package:p001/services/auth/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Register',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Container(
                      width: 300,
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Image.asset('assets/4.png')),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: false,
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      // Add a border around the TextField
                      borderRadius: BorderRadius.circular(
                          10.0), // You can adjust the border radius as needed
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: true,
                  controller: _password,
                  enableSuggestions: false,
                  autocorrect: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      // Add a border around the TextField
                      borderRadius: BorderRadius.circular(
                          10.0), // You can adjust the border radius as needed
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;

                  try {
                    await AuthService.firebase().createUser(
                      email: email,
                      password: password,
                    );
                    AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(
                      verifyRote,
                    );
                  } on InvalidEmailAuthException {
                    await showErrorDialog(
                      context,
                      'The email address is badly formatted',
                    );
                  } on WeakPasswordAuthException {
                    await showErrorDialog(
                      context,
                      'The given password is invalid [password should be at least 6 characters]',
                    );
                  } on EmailAlreadyInUseAuthException {
                    await showErrorDialog(
                      context,
                      'The email is already in use by another account',
                    );
                  } on GenericAuthException {
                    await showErrorDialog(
                      context,
                      'Failed to registred',
                    );
                  }
                },
                child: const Text(
                  'Register',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      },
                      child: const Text(
                        'Already Registered? Login  here ! ',
                        style: TextStyle(color: Colors.white),
                      )))
            ],
          ),
        ));
  }
}
