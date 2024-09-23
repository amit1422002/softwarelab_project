 import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

signInWithGoogle() async {
     GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
     GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
   UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
   print(userCredential.user?.displayName); 
  }

  signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      print('Signed in: ${userCredential.user!.displayName}');
    } catch (e) {
      print('Error signing in with Apple: $e');
    }
  }

Future<void> loginWithFacebook() async {
  try {
    // Trigger the sign-in flow
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) { 
      final AccessToken accessToken = result.accessToken!;
      final userData = await FacebookAuth.instance.getUserData();
      print('User data: ${userData}');
      
      
    } else { 
      print('Login failed: ${result.status}');
    }
  } catch (error) {
    print('Error logging in: $error');
  }
}