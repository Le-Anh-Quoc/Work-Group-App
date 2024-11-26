import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/screens/authentication/LoginScreen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // đăng nhập
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Lấy token và lưu vào biến toàn cục
        String? token = await user.getIdToken();
        print('token: $token');

        // Thông báo đăng nhập thành công
        print("Login Successful. Token: $token");
        return user;
      } else {
        // Thông báo đăng nhập thất bại
        print("Login Failed");
        return null;
      }
    } catch (e) {
      // Xử lý lỗi và thông báo
      print("Error: $e");
      return null;
    }
  }

// đăng xuất
  Future logOut(BuildContext context) async {
    //FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.signOut().then((value) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
    } catch (e) {
      // ignore: avoid_print
      print("error");
    }
  }

  // gửi email xác thực về email của người dùng
  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }

  // tạo tài khoản bằng Email
  Future<User?> registerWithEmail(
      String fullname, String email, String password) async {
    //final FirebaseAuth _auth = FirebaseAuth.instance;
    //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Đăng ký tài khoản
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Gửi email xác thực
      await userCredential.user!.sendEmailVerification();

      // ignore: avoid_print
      print('Email verification sent.');

      // Đợi người dùng xác thực email
      await checkEmailVerificationAndSave(fullname, email, _auth, _firestore);
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi FirebaseAuth
      throw e.message ?? 'Registration error';
    } catch (e) {
      // Xử lý các lỗi khác
      throw 'An unexpected error occurred';
    }
    return null;
  }

  // kiểm tra xem email đã được người dùng xác thực hay chưa để tiến hành lưu vào csdl
  Future<void> checkEmailVerificationAndSave(String fullname, String email,
      // ignore: no_leading_underscores_for_local_identifiers
      FirebaseAuth _auth, FirebaseFirestore _firestore) async {
    User? user = _auth.currentUser;
    if (user != null) {
      while (!(user!.emailVerified)) {
        // ignore: avoid_print
        print("Waiting for email verification...");
        await Future.delayed(
            const Duration(seconds: 3)); // Đợi 3 giây trước khi thử lại
        await user.reload(); // Làm mới trạng thái người dùng
        user = _auth.currentUser; // Cập nhật đối tượng người dùng
      }

      UserModel userModel =
          UserModel(userId: user.uid, fullname: fullname, email: email);

      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      // ignore: avoid_print
      print("Thông tin người dùng đã được lưu vào Firestore.");
    } else {
      // ignore: avoid_print
      print("Người dùng chưa được xác thực.");
    }
  }
}
