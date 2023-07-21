import 'package:cooky/pages/shared/ProviderModel.dart';
import 'package:cooky/pages/welcome/WelcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final RoundedLoadingButtonController _disconnectBtnController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {

    String Name = Provider.of<ProviderModel>(context).Name;
    String ProfilePicture = Provider.of<ProviderModel>(context).ProfilePicture;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Container(
                  width: 130,
                  height: 130,
                  child: ClipOval(
                    child: Image.network(
                      ProfilePicture,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 25,),
                Text(
                  Name,
                  style:
                  TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 25),
                RoundedLoadingButton(
                    child: Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.redAccent,
                    controller: _disconnectBtnController,
                    onPressed: () => _onClickDisconnectButton()
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onClickDisconnectButton(){
    FirebaseAuth.instance.signOut();
    _disconnectBtnController.success();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WelcomePage(),
      ),
    );
  }
}
