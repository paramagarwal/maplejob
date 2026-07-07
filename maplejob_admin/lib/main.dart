import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/config/theme.dart';
import 'app/config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: MapleJobAdmin(),
    ),
  );
}

class MapleJobAdmin extends StatelessWidget {
  const MapleJobAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MapleJob Admin',
      theme: AppTheme.lightTheme,
      routerConfig: adminRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
