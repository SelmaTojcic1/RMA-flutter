// @dart=2.9

import 'package:flutter/material.dart';
import 'package:my_pantry/pages/splash.dart';
import 'package:my_pantry/pages/home.dart';
import 'package:my_pantry/pages/add_ingredient.dart';

void main() => runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const Splash(),
      '/home': (context) => const Home(),
      '/add': (context) => const AddIngredient(),
    }
));
