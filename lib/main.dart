import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totenvalen/pages/home.dart';
import 'package:totenvalen/pages/placa.dart';
import 'package:totenvalen/pages/placa_insert.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    // overlays: [SystemUiOverlay.top],
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
