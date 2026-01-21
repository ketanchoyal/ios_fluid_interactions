import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ios_fluid_interactions/ios_fluid_interactions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // A dark theme to showcase the glass-morphism effect
    return MaterialApp(
      title: 'Fluid Nav Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        useMaterial3: true,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _currentIndex = 0;
  final ValueNotifier<bool> _shrinkNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _shrinkNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for glass effect
      backgroundColor: Colors.grey,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse &&
              !_shrinkNotifier.value) {
            _shrinkNotifier.value = true;
          } else if (notification.direction == ScrollDirection.forward &&
              _shrinkNotifier.value) {
            _shrinkNotifier.value = false;
          }
          return false;
        },
        child: Stack(
          children: [
            // Background content
            Positioned.fill(
              child: ListView.builder(
                itemCount: 50,
                padding: const EdgeInsets.only(bottom: 120),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Item $index',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Text('${index + 1}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FluidBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              // Auto-expand on tap
              _shrinkNotifier.value = false;
              if (index == 1) {
                _shrinkNotifier.value = true;
              }
            },
            shrinkNotifier: _shrinkNotifier,

            // Custom Theme
            theme: FluidBottomNavBarTheme(
              backgroundColor: Colors.white.withOpacity(0.5),
              iconActiveColor: Colors.white,
              iconInactiveColor: Colors.white38,
              shadowColor: Colors.white,
              labelActiveColor: Colors.white,
              labelInactiveColor: Colors.white38,
            ),

            // Navigation Items
            destinations: [
              const FluidNavDestination(
                icon: CupertinoIcons.home,
                filledIcon: CupertinoIcons.house_fill,
                label: 'Home',
              ),
              const FluidNavDestination(
                icon: CupertinoIcons.compass,
                filledIcon: CupertinoIcons.compass_fill,
                label: 'Explore',
              ),
              const FluidNavDestination(
                icon: CupertinoIcons.person,
                filledIcon: CupertinoIcons.person_fill,
                label: 'Profile',
              ),
            ],

            // Floating Widget (visible on specific tab when shrunk)
            floatingWidgetTabIndex: 1, // Show on 'Explore' tab

            floatingWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            // Trailing Action Button
            trailingButtonConfig: FluidTrailingActionButtonConfig(
              iconBuilder: (currentIndex) {
                if (currentIndex == 1) return CupertinoIcons.alarm;
                if (currentIndex == 2) return CupertinoIcons.add;
                return CupertinoIcons.add;
              },
              onTap: (index) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Action on tab $index'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              backgroundColor: CupertinoColors.activeBlue,
              iconColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
