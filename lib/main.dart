// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/word_service.dart';
import 'core/services/insight_cache_service.dart';
import 'features/game/game_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await StorageService.init();
  await InsightCacheService.init();

  final storage = StorageService();
  final wordService = WordService(storage);
  final insightCache = InsightCacheService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(
        storage: storage,
        wordService: wordService,
        insightCache: insightCache,
      )..init(),
      child: const WordWipeoutApp(),
    ),
  );
}

class WordWipeoutApp extends StatelessWidget {
  const WordWipeoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return MaterialApp(
      title: 'Word Wipeout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
