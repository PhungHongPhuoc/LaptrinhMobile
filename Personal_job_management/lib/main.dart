import 'package:flutter/material.dart';
import 'widgets/signup.dart';
import 'widgets/third.dart';
import 'widgets/dangki.dart';
void main() {
  runApp( MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Personnal job app",
      initialRoute: "/",
      routes: {
         "/": (ctx) => LoginScreen(),// signup, trang dang nhap va dang ki
        // "/second": (ctx) => SecondScreen(),
         "/Third": (ctx) => HomePage(),
        "/Four" : (ctx) => DkiScreen(),// trang dang ki tai khoan
      },
    );
  }
}
