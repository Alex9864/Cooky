import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooky/pages/shared/ProviderModel.dart';
import 'package:cooky/pages/shared/Widgets/PostCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {

    String Name = Provider.of<ProviderModel>(context).Name;
    String ProfilePicture = Provider.of<ProviderModel>(context).ProfilePicture;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Welcome back "+Name,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      child: ClipOval(
                        child: Image.network(
                          ProfilePicture,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Let's Cook(y) !",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FutureBuilder(
                future: fetchRecipesFromDatabase(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final List<Map<String, dynamic>> recipes = snapshot.data as List<Map<String, dynamic>>;
                    return Column(
                      children: recipes.map((recipe) {
                        final DocumentReference docRef = recipe["documentReference"];
                        return PostCard(
                          content: recipe["Content"],
                          dateOfPost: recipe["DateOfPost"],
                          imageUrl: recipe["ImageUrl"],
                          ingredients: recipe["Ingredients"],
                          likes: recipe["Likes"],
                          owner: recipe["Owner"],
                          preparationTime: recipe["PreparationTime"],
                          tags: recipe["Tags"],
                          title: recipe["Title"],
                          documentReference: docRef,
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>?> fetchRecipesFromDatabase() async {
    try {
      // Get a reference to the collection "posts"
      CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

      // Fetch all documents from the collection
      QuerySnapshot querySnapshot = await postsCollection.get();

      // Convert documents to a List<Map<String, dynamic>>
      List<Map<String, dynamic>> recipesList = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> recipeData = doc.data() as Map<String, dynamic>; // Convert Object? to Map<String, dynamic>
        recipeData['id'] = doc.id; // Optionally, you can add the document ID to the data
        recipeData['documentReference'] = doc.reference; // Ajouter la référence du document à la liste
        recipesList.add(recipeData);
      });

      // Sort the recipesList based on the "Likes" field in descending order
      recipesList.sort((a, b) => (b['Likes'] ?? 0).compareTo(a['Likes'] ?? 0));

      return recipesList;
    } catch (e) {
      print('Error fetching recipes: $e');
      return null; // Return null in case of an error
    }
  }
}
