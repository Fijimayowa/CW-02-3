import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;

Future<void> register(String email, String password) async {
  await _auth.createUserWithEmailAndPassword(email: email, password: password);
}

Future<void> signIn(String email, String password) async {
  await _auth.signInWithEmailAndPassword(email: email, password: password);
}

Future<void> logOut() => _auth.signOut();

/// Short, safe messages that don't expose sensitive details.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address does not look right.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'network-request-failed':
        return 'Network problem. Check your connection and try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
