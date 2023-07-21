import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooky/pages/recipeDetails/RecipeDetailsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
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

  const PostCard({
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
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsPage(
                    title: title,
                    ingredients: ingredients,
                    preparationTime: preparationTime,
                    content: content,
                    dateOfPost: dateOfPost,
                    imageUrl: imageUrl,
                    likes: likes,
                    owner: owner,
                    tags: tags,
                    documentReference: documentReference,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: 250,
                    width: 350,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 18),
                        SizedBox(width: 5),
                        Text(
                          preparationTime,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: FutureBuilder<dynamic>(
                    future: fetchOwnerProfilePicture(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final String profileImageUrl = snapshot.data?['ProfilePicture'] ?? '';
                        return CircleAvatar(
                          backgroundImage: NetworkImage(profileImageUrl),
                          radius: 25,
                        );
                      }
                    },
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
                        Icon(Icons.favorite, color: Colors.red, size: 18),
                        SizedBox(width: 5),
                        Text(
                          '$likes',
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
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 5,
            children: tags.map((tag) {
              return Chip(label: Text(tag.toString()));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<dynamic> fetchOwnerProfilePicture() async {
    try {
      // Get a reference to the document of the owner in "users" collection
      DocumentReference<Map<String, dynamic>> userDocumentRef = FirebaseFirestore.instance.collection('users').doc(owner);

      // Fetch the owner's document
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocumentRef.get();
      return userSnapshot;
    } catch (e) {
      print('Error fetching owner profile picture: $e');
      return null; // Return null in case of an error
    }
  }
}
