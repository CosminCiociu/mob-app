import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController extends GetxController {
  String imageUrl = '';

  bool isLoading = false;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode ageFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipCodeFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();

  File? imageFile;

  bool isSubmitLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

// Fetch profile data from Firestore
  Future<void> fetchProfileData() async {
    isLoading = true;
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          displayNameController.text = data?['displayName'] ?? '';
          emailController.text = data?['email'] ?? '';
          ageController.text = data?['age']?.toString() ?? '';
          mobileNoController.text = data?['mobileNo'] ?? '';
          addressController.text = data?['address'] ?? '';
          stateController.text = data?['state'] ?? '';
          zipCodeController.text = data?['zipCode'] ?? '';
          cityController.text = data?['city'] ?? '';
          imageUrl = data?['photoURL'] ?? '';
        }
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
    isLoading = false;
    update();
  }

  Future<void> updateProfile() async {
    isSubmitLoading = true;
    update();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'displayName': displayNameController.text,
          'email': emailController.text,
          'age': ageController.text.isNotEmpty
              ? int.tryParse(ageController.text)
              : null,
          'mobileNo': mobileNoController.text,
          'address': addressController.text,
          'state': stateController.text,
          'zipCode': zipCodeController.text,
          'city': cityController.text,
          'updatedAt': FieldValue.serverTimestamp(),
          // Add other fields as necessary
        });
      }
    } catch (e) {
      print('Error updating profile data: $e');
    }
    isSubmitLoading = false;
    update();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    update();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
