import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:string_validator/string_validator.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  currentUser() async {
    return _auth.currentUser;
  }

  String get currentUserId {
    return _auth.currentUser.uid;
  }

  currentUserEmail() async {
    return _auth.currentUser.email.toString();
  }

  currentUserName() async {
    return _auth.currentUser.displayName;
  }

  Future<UserCredential> signInWithEmailAndPassword(email, password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String> changeEmail(newEmail) async {
    try {
      await _auth.currentUser.updateEmail(newEmail);
      return 'Email successfully changed';
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return (e.message);
    }
  }

  Future<String> changeName(newName) async {
    try {
      await _auth.currentUser.updateDisplayName(newName);
      return 'User name successfully changed';
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return (e.message);
    }
  }

  Future<String> changePassword(newPassword) async {
    try {
      await _auth.currentUser.updatePassword(newPassword);
      return 'User password successfully changed';
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return (e.message);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    // by default we request the email and the public profile
// or FacebookAuth.i.login()
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken;
      final facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.token);
      return await _auth.signInWithCredential(facebookAuthCredential);
    }
  }

  Future sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }
}

class EmailValidator {
  static String validate(String email) {
    if (email == null || email.isEmpty) {
      return "Email can't be empty!";
    } else if (!isEmail(email)) {
      return "Not a valid e-mail!";
    }
    return null;
  }
}

class NameValidator {
  static String validate(String name) {
    String pattern = r'^[a-zA-Z0-9\s]+$';
    if (name == null || name.isEmpty) {
      return "Name can't be empty!";
    } else if (name.length < 3) {
      return "Name can't be shorter than 3 characters!";
    } else if (name.length > 20) {
      return "Name can't be longer than 20 characters!";
    } else if (!isAlpha(name[0])) {
      return "First character of a name must be a letter!";
    }
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(name)) {
      return "Name must be alphanumerical characters only!";
    }
    return null;
  }
}

class PasswordValidator {
  static String validate(String value, value2) {
    if (value == null || value.isEmpty) {
      return "Şifre Boş Olamaz!";
    }
    if (value2 != value) {
      return "Şifreler Eşleşmiyor!";
    }
    String pattern = r'^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~,.]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return "Password must contain at least 8 characters, a letter, number and special character!";
    }
    return null;
  }
}
