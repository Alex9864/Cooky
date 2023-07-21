import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooky/pages/authentication/AccountCreationPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class OtpPageCreate extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int resendToken;

  const OtpPageCreate({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    required this.resendToken
  }) : super(key: key);

  @override
  State<OtpPageCreate> createState() => _OtpPageCreateState();
}

class _OtpPageCreateState extends State<OtpPageCreate> {

  final db = FirebaseFirestore.instance;
  final user = <String, dynamic>{
    "FirstName": "",
    "LastName": "",
  };

  final _textFieldFormKey = GlobalKey<FormState>();
  final TextEditingController _otpCodeTextFormFieldController = TextEditingController();
  final RoundedLoadingButtonController _verifyBtnController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
                Text("Verify the code",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text("We've sent a verification code to " + widget.phoneNumber,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Form(
                    key: _textFieldFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      autofocus: true,
                      controller: _otpCodeTextFormFieldController,
                      decoration: InputDecoration(
                          icon: Icon(Icons.phone_android),
                          hintText: "000000",
                          labelText: "Your verification code"
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    )
                ),
                SizedBox(height: 30),
                RoundedLoadingButton(
                  child: Text('Verify', style: TextStyle(color: Colors.white)),
                  color: Colors.redAccent,
                  successColor: Colors.green,
                  controller: _verifyBtnController,
                  onPressed: () => _verifyPhoneNumberInFirebase(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyPhoneNumberInFirebase() async {
    if(_otpCodeTextFormFieldController.text.isNotEmpty){
      try {
        PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
            verificationId: widget.verificationId,
            smsCode: _otpCodeTextFormFieldController.text
        );

        await FirebaseAuth.instance.signInWithCredential(authCredential);

        Navigator.pop(context);
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AccountCreationPage(phoneNumber: widget.phoneNumber,)
            )
        );
      } on FirebaseAuthException {
        print("Code OTP expiré ou invalide");
        _verifyBtnController.success();
      }

    } else {
      _verifyBtnController.error();
    }
  }

  // void changeUser(String FirstName, String LastName) {
  //   final imageModel = Provider.of<ProviderModel>(context, listen: false);
  //   imageModel.setFirstName(FirstName);
  //   imageModel.setLastName(LastName);
  // }

}
