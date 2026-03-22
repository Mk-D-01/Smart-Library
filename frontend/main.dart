import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My App'),
        ),
        body: Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
    );
  }
}

class MySecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Second Page'),
      ),
    );
  }
}
class MyThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Third Page'),
      ),
    );
  }
}

//steps to run this :
/*
1. flutter create .
2. flutter run
3. flutter build
4. flutter deploy
5. flutter test
6. flutter analyze
7. flutter format
8. flutter pub get
9. flutter pub upgrade
10. flutter pub outdated
11. flutter pub upgrade --major
run these commands in the terminal to run the app
series of commands to run the app is as per the numbering in the steps to run the app:*/
