import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'Settings/helper/providers.dart';
import 'Settings/utils/p_colors.dart';
import 'Settings/utils/p_pages.dart';
import 'Settings/utils/p_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase based on platform
  if (kIsWeb) {
    // For web, Firebase is already initialized in index.html
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAxe6NJEd2C_MG4o0EPN9GlJWOBTLOBzbA",
        authDomain: "freshfold-31734.firebaseapp.com",
        projectId: "freshfold-31734",
        storageBucket: "freshfold-31734.firebasestorage.app",
        messagingSenderId: "721774046319",
        appId: "1:721774046319:web:ccee433e4688007013b19a",
        measurementId: "G-L4E0YGQYKP",
      ),
    );
  } else {
    // For mobile platforms (Android/iOS)
    await Firebase.initializeApp();
  }
  
  // Load .env file (only works on mobile/desktop, not web)
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }
  
  runApp(MultiProvider(providers: providers, child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'FreshFold',
      theme: ThemeData(
        brightness: Brightness.light,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: PColors.scaffoldColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PColors.white,
          brightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: PColors.white),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: PColors.colorFFFFFF,
          surfaceTintColor: PColors.colorFFFFFF,
          foregroundColor: PColors.white,
          centerTitle: false,
        ),
      ),
      initialRoute: PPages.splash,
      onGenerateRoute: Routes.genericRoute,
    );
  }
}
