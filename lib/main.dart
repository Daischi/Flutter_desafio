import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/media_provider.dart';
import 'services/tmdb_service.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => MediaProvider(
            tmdbService: TMDBService(
              apiKey: '064c5a7beffb11077a28b78eb08881c0',
            ),
          ),
      child: MaterialApp(
        title: 'PoppiStream',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
