import 'package:flutter/foundation.dart';

class ProviderModel extends ChangeNotifier {
  String Name = "NameDebug";
  String ProfilePicture = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";

  void setName(String newName) {
    Name = newName;
    notifyListeners();
  }
  void setProfilePicture(String newProfilePicture) {
    ProfilePicture = newProfilePicture;
    notifyListeners();
  }
}