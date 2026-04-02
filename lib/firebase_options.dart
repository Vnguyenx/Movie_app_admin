import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDHrXScESJfO9hD5pI17qYO6ClglvxZw4c",
    authDomain: "trailer-movie-app-f01ab.firebaseapp.com",
    projectId: "trailer-movie-app-f01ab",
    storageBucket: "trailer-movie-app-f01ab.firebasestorage.app",
    messagingSenderId: "485055435777",
    appId: "1:485055435777:web:b803279598b3568e159c00",
  );
}