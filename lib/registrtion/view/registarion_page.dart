import 'dart:developer';

import 'package:firbasse_chatapp/chat/view/chatshow_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

class RegistraionPage extends StatefulWidget {
  const RegistraionPage({super.key});

  @override
  State<RegistraionPage> createState() => _RegistraionPageState();
}

final TextEditingController controller = TextEditingController();

class _RegistraionPageState extends State<RegistraionPage> {
  bool? showButton = false;
  User? user;

  Future<User?> signwithGoogle() async {
    await Firebase.initializeApp();
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }
    if (user != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(
                    userdata: user,
                  )),
        );
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        margin: const EdgeInsets.only(left: 0, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Container(
              width: 300,
              height: 500,
              child: Lottie.asset('assets/Animation - 1697793612000.json'),
            ),
            const Spacer(),
            showButton == false
                ? Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        onPressed: () {
                          FutureBuilder(
                              future: signwithGoogle(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  log("error is => ${snapshot.error.toString()}");
                                  return const Text(
                                      'Error initializing Firebase');
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  //return GoogleSignInButton();
                                  setState(() {
                                    showButton = true;
                                  });
                                }
                                return const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                );
                              });
                        },
                        child: const Text("Sign With Google")),
                  )
                : const Text("feching google data"),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  log(user!.displayName.toString());
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPage(
                                userdata: user,
                              )),
                    );
                  }
                },
                child: const Text("Start Chating")),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      )),
    );
  }
}
