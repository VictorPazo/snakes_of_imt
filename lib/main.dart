import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens/home.dart';
import 'screens/login.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // 🌍 LOCALIZAÇÃO
  await EasyLocalization.ensureInitialized();

  // ☁️ SUPABASE
  await Supabase.initialize(
    url: 'https://onisczwmchpouqrkxhli.supabase.co',

    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uaXNjendtY2hwb3Vxcmt4aGxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxMDUzOTcsImV4cCI6MjA5MzY4MTM5N30.XgGudHdIjJiIVOKG4i07UueyO3bA3tKcKdf4zCzzbnM',
  );

  runApp(

    EasyLocalization(

      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],

      path: 'assets/translations',

      fallbackLocale: const Locale('pt', 'BR'),

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final session =
        Supabase.instance.client.auth.currentSession;

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Snakes of IMT',

      // 🌍 LOCALIZAÇÃO
      localizationsDelegates:
      context.localizationDelegates,

      supportedLocales:
      context.supportedLocales,

      locale:
      context.locale,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF126516),
        ),

        useMaterial3: true,
      ),

      // 🔥 LOGIN AUTOMÁTICO
      home: session != null
          ? const HomePage()
          : LoginPage(),
    );
  }
}