import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/components/login_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text('Logged in '),
        ),
        // logout button
        ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) =>
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => AuthPage())));
            },
            child: Text(
              'Logout',
            ))
      ],
    ));
  }
}
