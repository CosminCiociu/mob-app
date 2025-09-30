import 'package:firebase_auth/firebase_auth.dart';
import '../data/model/auth/sign_up_model/sign_up_model.dart';
import 'package:ovo_meet/core/utils/my_strings.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUp(SignUpModel signUpModel) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: signUpModel.email,
        password: signUpModel.password,
      );

      // Update display name with first and last name
      await result.user?.updateDisplayName(
        '${signUpModel.firstName} ${signUpModel.lastName}',
      );

      return result;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception(MyStrings.somethingWentWrong);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(MyStrings.somethingWentWrong);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(MyStrings.signOutError);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return MyStrings.noUserFound;
      case 'wrong-password':
        return MyStrings.wrongPassword;
      case 'email-already-in-use':
        return MyStrings.emailAlreadyInUse;
      case 'weak-password':
        return MyStrings.weakPassword;
      case 'invalid-email':
        return MyStrings.invalidEmail;
      case 'user-disabled':
        return MyStrings.userDisabled;
      case 'too-many-requests':
        return MyStrings.tooManyRequests;
      case 'operation-not-allowed':
        return MyStrings.operationNotAllowed;
      default:
        return e.message ?? MyStrings.somethingWentWrong;
    }
  }
}
