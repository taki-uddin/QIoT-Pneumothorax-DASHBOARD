// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAds6uGAnChbX4tnFete6ox9gclRF2qIHc",
  authDomain: "qiot-pneumothorax-app.firebaseapp.com",
  projectId: "qiot-pneumothorax-app",
  storageBucket: "qiot-pneumothorax-app.appspot.com",
  messagingSenderId: "1037772283044",
  appId: "1:1037772283044:web:6b1d46396ba4c1f4501a31",
  measurementId: "G-MYY3VCE1NJ"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});