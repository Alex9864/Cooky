import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooky/pages/authentication/AuthenticationPage.dart';
import 'package:cooky/pages/authentication/ConnexionPage.dart';
import 'package:cooky/pages/bottomNavigationBar/BottomNavigationBarPage.dart';
import 'package:cooky/pages/shared/ProviderModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  final db = FirebaseFirestore.instance;

  final RoundedLoadingButtonController _getStartedBtnController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _haveAnAccountBtnController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            getUserInfos();
            return BottomNavigationBarPage();
          } else {
          return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/CookyLogo.png',
                        height: 300,
                      ),
                      SizedBox(height: 30),
                      Text("Welcome to Cooky !",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25
                        ),),
                      SizedBox(height: 10),
                      Text("Let's connect to your account first !",
                        style: TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: 15
                        ),),
                      SizedBox(height: 30),
                      RoundedLoadingButton(
                        child: Text(
                            'Create an account', style: TextStyle(color: Colors
                            .white)),
                        color: Colors.redAccent,
                        successColor: Colors.green,
                        controller: _getStartedBtnController,
                        onPressed: () => _onClickGetStartedButton(),
                      ),
                      SizedBox(height: 30),
                      RoundedLoadingButton(
                        child: Text('I already have an account',
                            style: TextStyle(color: Colors.white)),
                        color: Colors.grey.withOpacity(0.8),
                        controller: _haveAnAccountBtnController,
                        onPressed: _onClickAlreadyHaveAnAccountButton,
                      ),
                    ],
                  ),
                ),
              )
            );
          }
        }
      ),
    );
  }

  void getUserInfos(){
    final user = FirebaseAuth.instance.currentUser!;
    final DocumentReference _docRef = db.collection('users').doc(user.uid);

    _docRef.get().then((DocumentSnapshot docSnap) {
      if (docSnap.exists) {
        Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
        String Name = data['Name'];
        String ProfilePicture = data['ProfilePicture'];
        changeUser(Name, ProfilePicture);
      } else {
        // Handle the case where the document does not exist
      }
    });
  }

  void changeUser(String Name, String ProfilePicture) {
    final providerModel = Provider.of<ProviderModel>(context, listen: false);
    providerModel.setName(Name);
    providerModel.setProfilePicture(ProfilePicture);
  }

  void _onClickGetStartedButton(){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const AuthenticationPage()
        )
    );
    _getStartedBtnController.stop();
  }

  void _onClickAlreadyHaveAnAccountButton(){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const ConnexionPage()
        )
    );
    _haveAnAccountBtnController.stop();
  }

}
