import 'package:cooky/pages/shared/ProviderModel.dart';
import 'package:cooky/pages/welcome/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProviderModel(),
      child: MaterialApp(
        title: 'Cooky',
        theme: ThemeData(
          primaryColor: Colors.orange,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: const WelcomePage(),
        debugShowCheckedModeBanner: false
      ),
    );
  }
}