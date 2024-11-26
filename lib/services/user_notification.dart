// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';


//import 'package:googleapis/servicecontrol/v1.dart' as serviceControl;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
//import 'package:path/path.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:http/http.dart' as http;
class FirebaseAPI {
  static FirebaseAuth  get _auth => FirebaseAuth.instance;
  static User get user => _auth.currentUser!;
   final FirebaseFirestore _db = FirebaseFirestore.instance;
  static UserModel me= UserModel(
    userId: user.uid, 
    fullname: user.displayName!, 
    email:user.email! , 
    pushToken: '',
    );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    
    await fMessaging.getToken().then((t){
      if (t != null) {
        _db.collection('users')
        .doc(user.uid)
        .update({
          'pushToken': t
        });
         print('token:  $t');
       }
    });
  

  } 
  Future<String> getAccessToken()async{
    final serviceAccountJson={
      "type": "service_account",
      "project_id": "ruprup-41858",
      "private_key_id": "cc455d544266814312faa37a1ea79a6518bc0ce7",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC3uHdFy3UHxBlt\nYpEIgCQBEMeppS7jL/vW+FvyX7r84QYEqObSEA44+bZwoTx4teXpQtkGlWGTFzP6\nGiG+BGjbJ5A019SnzpRvK6NrbA+RBrporlDRkgQnSV1RRQVn8tv86FMG2vvke3XG\n/4I8Dg3hq8bAY8uAKRQiohFzD0WQVv4QJucqF7OX0GG5CupXm8s34ycsKcczG4CY\nh0U2txbEN2gcaabVGbEGcQO/cPiPSV8HiwLQUnSkJPcGAzWoJccszKbHRIL8rlTm\ncf4NM9JfNFcc15+rRUU7pKYmUefvf7rMLmSo3dYwpt6Rw9+x+kg0mL0bhZG4ckCq\nnn0eujuDAgMBAAECggEAV51bFCfhGeEFF0tISzuA8BkmftrNr360pWIvxzisHeja\nS+KYoVkSz00XGkNqaU6l5EYC5cbbj6AjI4TOzqWfs9P8S5caTSSRWSsAdjxEeC8z\nOrTWyfrOjEXKgPVfjKEfFE9fOQe51M6j7lDvtOAm8pZO5HUzGV19wr5zf+GqlRh3\nBB3KuVSaESvQn3GT4Rue0J5pvvB6l6Nn61yUZtiide9NNwAJ6HJM5KYZ96oLnVvO\njd+ipunIXMnSLwwhDWkEQzWOxCBKkMYGC3YAtrNLRqpX/sWhBzQKfsyH9sJtSzyj\noUH475XSjE66IXy2fGxny5w1JdrWpbFj5tXKth64oQKBgQD1fnaJWxo/qACKbeTB\nhbz6CPfmw7fJ6kzb6+KG0gx5mzmBKpxjXAru2IA14DD81ANH2cBR8vpwxkxXz3UJ\nDCtLq0RdDyKpo5UUvtf/v8Z1J69s/k2fJrZ4hO9Xat3bik1JeL5bFSpfy3qUYj+S\nh4+ZehMrHObptj7Eg8K1rzLCuwKBgQC/lTy4PmzfAsAVUk5qU07SIafrQpnqeh3i\n2pMFO7g3cLKFAtQnJQRLvzUL0GAEDvUQ/TfGDu2jD62tT5Fmkn4lf8fujnsTWP7a\nR6Tm/DjYDHh928kwTAgPnErNc7rqhTECppALysmC7SHiOWvC9Wn58BL9MoBYfIp1\ntjxFrOJR2QKBgQDvuqUKkNpbGzYb+CCREoZuLF/ZC3roRFL1162INopUHk7TYccC\nCBntD6Jz+hAcdPUXLv7th7ckdaCLh10kjqug4wiJT4Rr4ABvF8ZaSu4D7dMTPmqS\nZf1+R2JqHUO1ZaL/gldxHoQYs91qFV87OgHywBED4t9jjsJQqNJ1FTcejQKBgGoe\n8mlkOs41Kc0lsEX5K3n+JpOMatGVHyTfyfxmHh6nkFtZO8cLHBwRKAMJQ4Y7+seU\nW+abskpWju+nWXUlxDZlV4vu5IHNFC447UD9iUczcTLWIdVc6EItYsn3RxxM9t7v\nAG9nvsOFMvWqtORjKHbH4tzZsnpRUijt7ujxYNPRAoGBANro2HsE3XmjQ7JDzyP8\nA6b2vTUPOtbpZIBJ6s0MaB1BNcwiUHVD3DGp3fYk3e/gySqvtWQoAmeZTRvnIpRX\niXqj3TT58hTmLNPJJDXjH15fV5aHT3Pv5cRVIX6ZL5H569B12mr9pvVcyQhXT2zM\nccomCpkIeOVzG93ccmAFtL4N\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-zcir1@ruprup-41858.iam.gserviceaccount.com",
      "client_id": "103671155953184409019",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-zcir1%40ruprup-41858.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes=[
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client= await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),scopes,
    );

    //get the acces token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
        client,
    );
   client.close();

   return credentials.accessToken.data;
  }
  Future<void> sendPushNotification(
       String pushToken, String msg) async {
     try {
      final body = {
        "message": {
          "token": pushToken,
          "notification": {
            "title": user.displayName, //our name should be send
            "body": msg,
          },
        }
       };
    
    const projectID = 'ruprup-41858';
     
    final String bearerToken= await getAccessToken() ;
    if (bearerToken == null) return;
       var res = await post(
         Uri.parse(
             'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
         headers: {
           HttpHeaders.contentTypeHeader: 'application/json',
           HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
           
         },
         body: jsonEncode(body),
         
       );
      // print('Response status: ${res.statusCode}');
      // print('Response body: ${res.body}');
     } catch (e) {
         print('\nsendPushNotificationE: $e');
     }
    
  }
  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

      await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Xử lý khi người dùng nhấn vào thông báo
        print("Notification clicked with payload: ${response.payload}");
      },
    );

    await fMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    NotificationSettings settings =
        await fMessaging.getNotificationSettings();
    print('User granted permission: ${settings.authorizationStatus}');

    final fCMToken = await fMessaging.getToken();
    print('Token:  $fCMToken');

    await fMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // Lắng nghe khi nhận được thông báo foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message in foreground!');
      print('Message data: ${message.data}');
      showNotification(message);
      if (message.notification != null) {
      //showNotification(message.notification?.title ?? "",message.notification?.body??"");
        

        print('Notification: ${message.notification!.title}, ${message.notification!.body}');
      }
    });
  }
   Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'payload data', // dữ liệu đính kèm có thể xử lý khi click vào thông báo
    );
  }
}