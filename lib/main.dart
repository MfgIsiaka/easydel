import 'package:osm/services/provider_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:osm/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor colorPrimarySwatch = MaterialColor(
      0xff097969,
      <int, Color>{
        50: Color(0xff097969),
        100: Color(0xff097969),
        200: Color(0xff097969),
        300: Color(0xff097969),
        400: Color(0xff097969),
        500: Color(0xff097969),
        600: Color(0xff097969),
        700: Color(0xff097969),
        800: Color(0xff097969),
        900: Color(0xff097969),
      },
    );
    return ChangeNotifierProvider<AppDataProvider>(
        create: (context) => AppDataProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              primary: colorPrimarySwatch, // Set your desired red color here
              seedColor: colorPrimarySwatch,
            ),
          ),
          home: const SplashScreen(),
        ));
  }
}
