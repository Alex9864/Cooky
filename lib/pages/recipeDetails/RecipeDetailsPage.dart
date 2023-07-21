import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipeDetailsPage extends StatefulWidget {
  final String content;
  final Timestamp dateOfPost;
  final String imageUrl;
  final List<dynamic> ingredients;
  final int likes;
  final String owner;
  final String preparationTime;
  final List<dynamic> tags;
  final String title;
  final DocumentReference documentReference;

  const RecipeDetailsPage({
    Key? key,
    required this.content,
    required this.dateOfPost,
    required this.imageUrl,
    required this.ingredients,
    required this.likes,
    required this.owner,
    required this.preparationTime,
    required this.tags,
    required this.title,
    required this.documentReference,
  }) : super(key: key);

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {

  bool _isLiked = false;
  int _totalLikes = 0;

  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUid();
    _checkIfLiked();
    _totalLikes = widget.likes;
  }

  Future<void> _getCurrentUserUid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserUid = user.uid;
      });
    }
  }

  Future<void> _checkIfLiked() async {
    try {
      // Get a reference to the document that holds the recipe details
      DocumentReference<Map<String, dynamic>> recipeDocumentRef = widget.documentReference as DocumentReference<Map<String, dynamic>>;

      // Get the current snapshot of the document
      DocumentSnapshot<Map<String, dynamic>> recipeSnapshot = await recipeDocumentRef.get();

      // Get the current value of "UserLikes" array from the snapshot
      List<dynamic> currentUserLikes = recipeSnapshot.data()?['UserLikes'] ?? [];

      // Check if the current user's UID exists in "UserLikes" array
      setState(() {
        _isLiked = currentUserLikes.contains(currentUserUid);
      });
    } catch (e) {
      print('Error checking if liked: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.imageUrl,
                        height: 250,
                        width: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Shared by',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 5),
                            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              future: _fetchOwnerProfileInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final String profileImageUrl = snapshot.data?['ProfilePicture'] ?? '';
                                  final String userName = snapshot.data?['Name'] ?? '';
                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(profileImageUrl),
                                        radius: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        userName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),

                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formatDate(widget.dateOfPost),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.favorite, color:Colors.red, size: 18),
                            SizedBox(width: 5),
                            Text(
                              '$_totalLikes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 250,
                      child: Align(
                        child: Wrap(
                          spacing: 5,
                          children: widget.tags.map((tag) {
                            return Chip(label: Text(tag.toString()));
                          }).toList(),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _updateLikes();
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                          SizedBox(width: 5),
                          Text(_isLiked ? 'Unlike' : 'Like'),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 30),
                    SizedBox(width: 5),
                    Text(
                      widget.preparationTime,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Ingredients:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.ingredients.map((ingredient) {
                    return Text('- $ingredient');
                  }).toList(),
                ),
                SizedBox(height: 16),
                Text(
                  'How to do it :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.content,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    // Format the Timestamp as "June 12 2023"
    DateTime date = timestamp.toDate();
    String formattedDate = '${_getMonthName(date.month)} ${date.day} ${date.year}';
    return formattedDate;
  }

  String _getMonthName(int month) {
    List<String> monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month];
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchOwnerProfileInfo() async {
    try {
      // Get a reference to the document of the owner in "users" collection
      DocumentReference<Map<String, dynamic>> userDocumentRef = FirebaseFirestore.instance.collection('users').doc(widget.owner);

      // Fetch the owner's document
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocumentRef.get();
      return userSnapshot;
    } catch (e) {
      print('Error fetching owner profile info: $e');
      rethrow; // Rethrow the error so that it can be handled by the caller
    }
  }

  Future<void> _updateLikes() async {
    try {
      // Get a reference to the document that holds the recipe details
      DocumentReference<Map<String, dynamic>> recipeDocumentRef = widget.documentReference as DocumentReference<Map<String, dynamic>>;

      // Get the current snapshot of the document
      DocumentSnapshot<Map<String, dynamic>> recipeSnapshot = await recipeDocumentRef.get();

      // Get the current value of "Likes" and "UserLikes" array from the snapshot
      int currentLikes = recipeSnapshot.data()?['Likes'] ?? 0;
      List<dynamic> currentUserLikes = recipeSnapshot.data()?['UserLikes'] ?? [];

      // If the user already liked the recipe, remove their UID from "UserLikes" array
      if (currentUserLikes.contains(currentUserUid)) {
        currentUserLikes.remove(currentUserUid);
        currentLikes--;
      } else {
        // If the user didn't like the recipe, add their UID to "UserLikes" array
        currentUserLikes.add(currentUserUid);
        currentLikes++;
      }

      // Update the document with the new values
      await recipeDocumentRef.update({
        'Likes': currentLikes,
        'UserLikes': currentUserLikes,
      });
      // Update the total likes count in the state
      setState(() {
        _totalLikes = currentLikes;
      });
    } catch (e) {
      print('Error updating likes: $e');
    }
  }

}
