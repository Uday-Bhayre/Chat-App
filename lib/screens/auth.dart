import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class authentication extends StatefulWidget {
  const authentication({super.key});

  @override
  State<authentication> createState() => _authenticationState();
}

class _authenticationState extends State<authentication> {
  File? _selectedImg;
  var _isLogin = false;
  var _enteredMail = '';
  var _enteredPass = '';
  var _enteredName = '';
  var _isAuthenticating = false;
  final form = GlobalKey<FormState>();
  void _submit() async {
    final isValid = form.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImg == null)) {
      return;
    }

    form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
            email: _enteredMail, password: _enteredPass);
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredMail, password: _enteredPass);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(_selectedImg!);
        final imgUrl = await storageRef.getDownloadURL();
        print(imgUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'user-name': _enteredName,
          'email-id': _enteredMail,
          'img-url': imgUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.toString() == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication Failed'),
        ),
      );
    }
    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                child: Column(
                  children: [
                    Image.asset('lib/assets/chat.png', fit: BoxFit.cover),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: form,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            userImagePicker(
                              onPickImg: (img) {
                                _selectedImg = img;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'At least 4 character is needed in name';
                                }
                                return null;
                              },
                              decoration:
                                  InputDecoration(labelText: 'User-Name'),
                              onSaved: (newValue) {
                                _enteredName = newValue!;
                              },
                            ),
                          TextFormField(
                            showCursor: true,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredMail = value!;
                              // print(_enteredMail);
                            },
                          ),
                          TextFormField(
                            autocorrect: false,
                            obscureText: true,
                            textCapitalization: TextCapitalization.none,
                            showCursor: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must contain atleast 6 character';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPass = value!;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              autofocus: true,
                              onPressed: () {
                                _submit();
                              },
                              child: Text(_isLogin ? 'Login' : 'SignUp'),
                            ),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'Already have an account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
