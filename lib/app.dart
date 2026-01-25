import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/add_edit_routine_screen.dart';
import 'screens/home_screen.dart';
import 'screens/routine_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

class DayliaApp extends StatefulWidget {
  const DayliaApp({super.key});

  @override
  State<DayliaApp> createState() => _DayliaAppState();
}

class _DayliaAppState extends State<DayliaApp> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Daylia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: (settings) {
        if (settings.name == '/routine-detail') {
          final routineId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(routineId: routineId),
          );
        }
        if (settings.name == '/add-edit-routine') {
          final routineId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => AddEditRoutineScreen(routineId: routineId),
          );
        }
        return null;
      },
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddEditRoutineScreen(),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
