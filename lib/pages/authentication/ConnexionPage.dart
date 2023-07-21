import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooky/pages/otp/OtpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({Key? key}) : super(key: key);

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {

  final _textFieldFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberTextFormFieldController = TextEditingController();
  final RoundedLoadingButtonController _verifyBtnController = RoundedLoadingButtonController();

  final db = FirebaseFirestore.instance;

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
                  Text("Sign in with your phone number !",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 30
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
                            labelText: "Your phone number"
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 14,
                      )
                  ),
                  SizedBox(height: 30),
                  RoundedLoadingButton(
                    child: Text('Continue', style: TextStyle(color: Colors.white)),
                    color: Colors.redAccent,
                    successColor: Colors.green,
                    controller: _verifyBtnController,
                    onPressed: () => _sendOtpCodeWithFirebase(),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }

  void _sendOtpCodeWithFirebase() async {
    if (_textFieldFormKey.currentState!.validate()) {
      if (_phoneNumberTextFormFieldController.text.isNotEmpty) {
        String phoneNumber = "+33${_phoneNumberTextFormFieldController.text}";

        // Rechercher le numéro de téléphone dans la base de données Firestore
        bool isPhoneNumberFound = await checkPhoneNumberExists(phoneNumber);

        if (isPhoneNumberFound) {
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OtpPage(
                  phoneNumber: phoneNumber,
                  verificationId: verificationId,
                  resendToken: resendToken!,
                ),
              ));
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          );
          _verifyBtnController.success();
        } else {
          // Afficher un message d'erreur car le numéro de téléphone n'a pas été trouvé dans la base de données
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No account registered with this phone number, create a new account.'),
              backgroundColor: Colors.red,
            ),
          );
          _verifyBtnController.error();
        }
      } else {
        _verifyBtnController.error();
      }
    } else {
      _verifyBtnController.error();
    }
  }

// Fonction pour vérifier si le numéro de téléphone existe dans la collection "users"
  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }

}
