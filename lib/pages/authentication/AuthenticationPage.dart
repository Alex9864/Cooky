import 'package:cooky/pages/otp/OtpPageCreate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _textFieldFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberTextFormFieldController = TextEditingController();

  final RoundedLoadingButtonController _verifyBtnController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Create a new account !",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Form(
                  key: _textFieldFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    controller: _phoneNumberTextFormFieldController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone_android),
                      hintText: "0610101010",
                      labelText: "Your phone number",
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 14,
                  ),
                ),
                SizedBox(height: 30),
                RoundedLoadingButton(
                  child: Text('Continue', style: TextStyle(color: Colors.white)),
                  color: Colors.redAccent,
                  successColor: Colors.green,
                  controller: _verifyBtnController,
                  onPressed: () => _checkPhoneNumberAndContinue(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkPhoneNumberAndContinue() async {
    if (_textFieldFormKey.currentState!.validate()) {
      if (_phoneNumberTextFormFieldController.text.isNotEmpty) {
        String phoneNumber = "+33${_phoneNumberTextFormFieldController.text}";

        // Check if the phone number exists in the "users" collection
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('Phone', isEqualTo: phoneNumber)
            .get();

        if (querySnapshot.size > 0) {
          // The phone number already exists in the database
          _verifyBtnController.error();
          _showSnackBar("An account with this phone number already exists.");
        } else {
          // The phone number does not exist in the database
          await _sendOtpCodeWithFirebase(phoneNumber);
          _verifyBtnController.success();
        }
      } else {
        _verifyBtnController.error();
      }
    } else {
      _verifyBtnController.error();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _sendOtpCodeWithFirebase(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpPageCreate(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              resendToken: resendToken!,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    _verifyBtnController.success();
  }
}
