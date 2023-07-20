import 'package:flutter/foundation.dart';

class ProviderModel extends ChangeNotifier {
  String firstName = "FirstNameDebug";
  String lastName = "LastNameDebug";

  void setFirstName(String newFirstName) {
    firstName = newFirstName;
    notifyListeners();
  }
  void setLastName(String newLastName) {
    lastName = newLastName;
    notifyListeners();
  }
}