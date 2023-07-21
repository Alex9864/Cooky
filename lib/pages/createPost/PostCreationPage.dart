import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PostCreationPage extends StatefulWidget {
  const PostCreationPage({Key? key}) : super(key: key);

  @override
  State<PostCreationPage> createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  String? _title;
  List<String> _ingredients = [];
  String? _preparationTime;
  List<String> _tags = [];
  String? _content;

  bool _isTitleValid = false;
  bool _areIngredientsValid = false;
  bool _isPreparationTimeValid = false;
  bool _areTagsValid = false;
  bool _isContentValid = false;
  bool _hasImage = false;

  int _selectedHour = 0; // Variable pour stocker l'heure choisie
  int _selectedMinute = 0; // Variable pour stocker les minutes choisies
  final List<int> _hours = List.generate(24, (index) => index); // Liste des heures de 0 à 23
  final List<int> _minutes = List.generate(60, (index) => index); // Liste des minutes de 0 à 59

  List<String> _selectedTags = [];

  File? _imageFile;

  TextEditingController _newIngredientController = TextEditingController();
  FocusNode _newIngredientFocusNode = FocusNode();

  final RoundedLoadingButtonController _postBtnController = RoundedLoadingButtonController();

  @override
  void dispose() {
    _newIngredientFocusNode.dispose();
    _newIngredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30),
                Text(
                  'Share your recipe with the world !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Photo of your recipe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _hasImage
                    ? InkWell(
                  onTap: _pickImage, // Allow changing the image again on tap
                  child: Image.file(
                    _imageFile!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                )
                    : IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.add_a_photo),
                  iconSize: 150,
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _title = value;
                    _isTitleValid = value.isNotEmpty;
                  },
                ),
                SizedBox(height: 40),
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                _buildIngredientsList(),
                SizedBox(height: 40),
                Text(
                  'Preparation time',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton<int>(
                      value: _selectedHour,
                      onChanged: (value) {
                        setState(() {
                          _selectedHour = value!;
                          _isPreparationTimeValid = _selectedHour > 0 || _selectedMinute > 0;
                        });
                      },
                      items: _hours.map((hour) {
                        return DropdownMenuItem<int>(
                          value: hour,
                          child: Text('$hour hour${hour != 1 ? 's' : ''}'),
                        );
                      }).toList(),
                    ),
                    SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _selectedMinute,
                      onChanged: (value) {
                        setState(() {
                          _selectedMinute = value!;
                          _isPreparationTimeValid = _selectedHour > 0 || _selectedMinute > 0;
                        });
                      },
                      items: _minutes.map((minute) {
                        return DropdownMenuItem<int>(
                          value: minute,
                          child: Text('$minute minute${minute != 1 ? 's' : ''}'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildSelectedTags(), // Show selected tags on the main page
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showTagsPopup(context),
                  child: Text('Choose Tags'),
                ),
                SizedBox(height: 40),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _content = value;
                    _isContentValid = value.isNotEmpty;
                  },
                  maxLines: null,
                  maxLength: 5000,
                ),
                SizedBox(height: 20),
                RoundedLoadingButton(
                  child: Text('Post !', style: TextStyle(color: Colors.white)),
                  color: Colors.redAccent,
                  successColor: Colors.green,
                  controller: _postBtnController,
                  onPressed: () => _onClickPostButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onClickPostButton() async {
    if (!_isTitleValid ||
        !_areIngredientsValid ||
        !_isPreparationTimeValid ||
        !_areTagsValid ||
        !_isContentValid ||
        !_hasImage) {
      _postBtnController.stop();
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // User not logged in
        return;
      }

      String formattedTime = _getFormattedTime();

      String? imageUrl;
      if (_imageFile != null) {
        // Upload the image to Firebase Storage and get the download URL
        imageUrl = await _uploadImageToFirebaseStorage(_imageFile!);
      }

      // Create a new document in the "posts" collection
      await FirebaseFirestore.instance.collection('posts').add({
        'Title': _title,
        'Ingredients': _ingredients,
        'PreparationTime': formattedTime,
        'Tags': _selectedTags,
        'Content': _content,
        'DateOfPost': DateTime.now(),
        'Owner': user.uid,
        'ImageUrl': imageUrl,
        'Likes': 0,
      });

      // Reset the form fields
      setState(() {
        _title = null;
        _ingredients.clear();
        _preparationTime = null;
        _selectedTags.clear();
        _content = null;
      });

      _postBtnController.success();

    } catch (e) {
      // Handle any errors that occur during saving
      print('Error saving post: $e');
      _postBtnController.stop();
    }
  }

  String _getFormattedTime() {
    if (_selectedHour == 0) {
      return '$_selectedMinute minute${_selectedMinute != 1 ? 's' : ''}';
    } else {
      return '$_selectedHour hour${_selectedHour != 1 ? 's' : ''} $_selectedMinute minute${_selectedMinute != 1 ? 's' : ''}';
    }
  }

  Widget _buildIngredientsList() {
    return Wrap(
      spacing: 8.0, // Horizontal spacing between ingredients
      runSpacing: 8.0, // Vertical spacing between ingredient rows
      children: List.generate(_ingredients.length, (index) {
        TextEditingController ingredientController = TextEditingController(text: _ingredients[index]);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '- ',
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: TextFormField(
                controller: ingredientController,
                decoration: InputDecoration(
                  labelText: 'Ingredient ${index + 1}',
                  counterText: '', // Hide the default counter text
                ),
                maxLength: 40,
                onChanged: (value) {
                  setState(() {
                    _ingredients[index] = value;
                    _areIngredientsValid = _ingredients.every((ingredient) => ingredient.isNotEmpty);
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _ingredients.removeAt(index);
                  _areIngredientsValid = _ingredients.isNotEmpty;
                });
              },
            ),
          ],
        );
      }).toList()
        ..add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '- ',
                style: TextStyle(fontSize: 20),
              ),
              Expanded(
                child: TextFormField(
                  focusNode: _newIngredientFocusNode,
                  controller: _newIngredientController,
                  decoration: InputDecoration(
                    labelText: 'New Ingredient',
                    counterText: '', // Hide the default counter text
                  ),
                  maxLength: 40,
                  onChanged: (value) {},
                  onEditingComplete: () {
                    _addNewIngredient();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _addNewIngredient,
              ),
            ],
          ),
        ),
    );
  }

  void _addNewIngredient() {
    String newIngredient = _newIngredientController.text.trim();
    if (newIngredient.isNotEmpty) {
      setState(() {
        _ingredients.add(newIngredient);
        _areIngredientsValid = _ingredients.isNotEmpty;
        _newIngredientController.text = '';
        _newIngredientFocusNode.unfocus(); // Remove focus after adding the ingredient
      });
    }
  }

  Widget _buildSelectedTags() {
    return Wrap(
      spacing: 8.0,
      children: _selectedTags.map((tag) {
        return Chip(
          label: Text(tag),
          deleteIcon: Icon(Icons.cancel),
          onDeleted: () {
            setState(() {
              _selectedTags.remove(tag);
            });
            _updateTagsValidity();
          },
        );
      }).toList(),
    );
  }

  void _updateTagsValidity() {
    setState(() {
      _areTagsValid = _selectedTags.isNotEmpty;
    });
  }

  void _showTagsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Tags'),
          content: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('contents').doc('posts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Text('No tags available.');
              }

              List<String> allTags = List.from(snapshot.data!.get('tags'));
              List<String> availableTags = allTags.where((tag) => !_selectedTags.contains(tag)).toList();

              return Wrap(
                spacing: 8.0,
                children: availableTags.map((tag) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTags.add(tag);
                        _areTagsValid = _selectedTags.isNotEmpty;
                      });
                      Navigator.pop(context);
                    },
                    child: Chip(label: Text(tag)),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _hasImage = true;
      });
    }
  }

  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      Reference reference = FirebaseStorage.instance.ref().child('images/$imageName.jpg');
      await reference.putFile(imageFile);
      String imageUrl = await reference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return '';
    }
  }
}
