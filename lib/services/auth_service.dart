import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timao/database/db_firestore.dart';
import 'package:flutter_timao/models/times.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User> _firebaseUser;
  var userIsAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();

    _firebaseUser = Rx<User>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.authStateChanges());

    ever(_firebaseUser, (User user) {
      userIsAuthenticated.value = true;
        });
  }

  User get user => _firebaseUser.value;
  static AuthService get to => Get.find<AuthService>();

  definirTime(Time time) async {
    final userId = _firebaseUser.value.uid;
    try {
      FirebaseFirestore db = await DBFirestore.get();
      await db.collection('usuarios').doc(userId).set({
        'time_id': time.id,
        'time_nome': time.nome,
      });
    } catch (e) {
      showSnack('Erro ao definir time', e.message);
    }
  }

  showSnack(String titulo, String erro) {
    Get.snackbar(
      titulo,
      erro,
      backgroundColor: Colors.grey[900],
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  createUser(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      showSnack('Erro ao registrar!', e.message);
    }
  }

  login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      showSnack('Erro no Login!', e.message);
    }
  }

  logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      showSnack('Erro ao sair!', e.message);
    }
  }
}
