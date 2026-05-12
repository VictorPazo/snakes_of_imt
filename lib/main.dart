import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snakes_of_imt/screens/screens.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://onisczwmchpouqrkxhli.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uaXNjendtY2hwb3Vxcmt4aGxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxMDUzOTcsImV4cCI6MjA5MzY4MTM5N30.XgGudHdIjJiIVOKG4i07UueyO3bA3tKcKdf4zCzzbnM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snakes of IMT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF126516),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}