import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooky/pages/bottomNavigationBar/BottomNavigationBarPage.dart';
import 'package:cooky/pages/shared/ProviderModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AccountCreationPage extends StatefulWidget {
  final String phoneNumber;

  const AccountCreationPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<AccountCreationPage> createState() => _AccountCreationPageState();
}

class _AccountCreationPageState extends State<AccountCreationPage> {

  final db = FirebaseFirestore.instance;
  final user = <String, dynamic>{
    "Name": "",
    "ProfilePicture": "",
    "Phone": "",
  };

  String _imageUrl = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

  final _nameTextFieldFormKey = GlobalKey<FormState>();
  final TextEditingController _nameTextFormFieldController = TextEditingController();

  final _profilePictureTextFieldFormKey = GlobalKey<FormState>();
  final TextEditingController _profilePictureTextFormFieldController = TextEditingController();

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
                    "Finalize your account !",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 130,
                    height: 130,
                    child: ClipOval(
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // En cas d'erreur de chargement de l'image, afficher l'image par défaut
                          return Image.network(
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _nameTextFormFieldController.text.isNotEmpty
                        ? _nameTextFormFieldController.text
                        : "Your Name",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Form(
                    key: _profilePictureTextFieldFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: _profilePictureTextFormFieldController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.image),
                        labelText: "URL of your profile picture",
                      ),
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  SizedBox(height: 30),
                  Form(
                    key: _nameTextFieldFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: _nameTextFormFieldController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person_outline),
                        labelText: "Your name",
                      ),
                      keyboardType: TextInputType.name,
                      maxLength: 20,
                    ),
                  ),
                  SizedBox(height: 30),
                  RoundedLoadingButton(
                    child: Text('Create your account', style: TextStyle(color: Colors.white)),
                    color: Colors.redAccent,
                    successColor: Colors.green,
                    controller: _verifyBtnController,
                    onPressed: () => _createAccount(),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameTextFormFieldController.addListener(_onNameTextFieldChanged);
    _profilePictureTextFormFieldController.addListener(_onProfilePictureTextFieldChanged);
  }

  @override
  void dispose() {
    _nameTextFormFieldController.removeListener(_onNameTextFieldChanged);
    _profilePictureTextFormFieldController.removeListener(_onProfilePictureTextFieldChanged);
    _nameTextFormFieldController.dispose();
    _profilePictureTextFormFieldController.dispose();
    super.dispose();
  }

  void _onNameTextFieldChanged() {
    setState(() {});
  }

  void _onProfilePictureTextFieldChanged() {
    setState(() {
      _imageUrl = _profilePictureTextFormFieldController.text.isNotEmpty
          ? _profilePictureTextFormFieldController.text
          : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
    });
  }

  void _createAccount() async {
    // Mettre à jour le champ 'Name'
    user['Name'] = _nameTextFormFieldController.text.isNotEmpty
        ? _nameTextFormFieldController.text
        : "Your Name";

    // Mettre à jour le champ 'ProfilePicture' en utilisant l'URL actuel ou l'URL par défaut si nécessaire
    final imageUrl = _profilePictureTextFormFieldController.text.isNotEmpty
        ? _profilePictureTextFormFieldController.text
        : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

    // Vérifier si l'image peut être chargée depuis l'URL
    final stream = Image.network(imageUrl).image.resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener((imageInfo, synchronousCall) {
      setState(() {
        // Si l'image peut être chargée, mettre à jour l'URL actuelle
        _imageUrl = imageUrl;
      });
    }, onError: (exception, stackTrace) {
      // Si l'image ne peut pas être chargée, utiliser l'URL par défaut
      setState(() {
        _imageUrl = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
      });
    }));

    user['ProfilePicture'] = _imageUrl;

    user['Phone'] = widget.phoneNumber;
    final cUser = FirebaseAuth.instance.currentUser!;
    db.collection("users").doc(cUser.uid).set(user);

    final providerModel = Provider.of<ProviderModel>(context, listen: false);
    providerModel.setName(user['Name']);
    providerModel.setProfilePicture(user['ProfilePicture']);

    getUserInfos();
    _verifyBtnController.success();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BottomNavigationBarPage(),
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

}
