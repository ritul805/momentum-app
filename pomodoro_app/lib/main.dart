import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PomodoroScreen(),
    );
  }
}

class NavItemData {
  final IconData icon;
  final String label;

  NavItemData({required this.icon, required this.label});
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _selectedIndex = 0;
  static const int initialTime = 25 * 60;
  int _remainingTime = initialTime;
  bool _isRunning = false;
  Timer? _timer;

  final List<NavItemData> navItems = [
    NavItemData(icon: Icons.bolt, label: "Focus"),
    NavItemData(icon: Icons.directions_run, label: "Move"),
    NavItemData(icon: Icons.school, label: "Learn"),
    NavItemData(icon: Icons.person, label: "Profile"),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _pauseTimer();
      }
    });

    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/image.png', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "POMODORO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "short break",
                    style: TextStyle(color: Color.fromARGB(255, 242, 238, 238)),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Focus",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "long break",
                    style: TextStyle(color: Color.fromARGB(255, 242, 238, 238)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color.fromARGB(255, 0, 7, 4), width: 4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(_remainingTime),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Minutes",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              IconButton(
                onPressed: _toggleTimer,
                icon: Icon(_isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                color: const Color.fromARGB(255, 140, 143, 141),
                iconSize: 64,
              ),
              Text(
                _isRunning ? "Pause" : "Start",
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isSelected = index == _selectedIndex;
                    return GestureDetector(
                      onTap: () => _onNavItemTapped(index),
                      child: NavItemWidget(
                        icon: item.icon,
                        label: item.label,
                        selected: isSelected,
                      ),
                    );
                  }),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class NavItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const NavItemWidget({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color.fromARGB(255, 255, 254, 254) : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}
