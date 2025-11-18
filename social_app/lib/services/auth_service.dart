// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// handles login, logout, register
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // register new user + create firestore record
  Future<String?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'student',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      return null; // no error means success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong.';
    }
  }

  // login existing user
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
