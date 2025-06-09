import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro App',
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PomodoroScreen(),
    const GenderSelectionScreen(),
    const PlaceholderScreen(title: 'Learn'),
    const PlaceholderScreen(title: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: 'Move'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------------- POMODORO SCREEN ----------------

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with TickerProviderStateMixin {
  final List<String> timerTypes = ['Focus', 'Short Break', 'Long Break'];
  final Map<String, int> timerDurations = {
    'Focus': 1500,
    'Short Break': 300,
    'Long Break': 900,
  };

  late String selectedType;
  late int remainingSeconds;
  Timer? _timer;
  bool isRunning = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    selectedType = 'Focus';
    remainingSeconds = timerDurations[selectedType]!;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedType = timerTypes[_tabController.index];
          remainingSeconds = timerDurations[selectedType]!;
          _timer?.cancel();
          isRunning = false;
        });
      }
    });
  }

  void toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds > 0) {
          setState(() => remainingSeconds--);
        } else {
          timer.cancel();
          setState(() => isRunning = false);
        }
      });
    }
    setState(() => isRunning = !isRunning);
  }

  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white70),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const TimerSettingsModal(),
                );
              },
            ),
            title: const Text('Pomodoro'),
            bottom: TabBar(
              controller: _tabController,
              tabs: timerTypes.map((e) => Tab(text: e)).toList(),
              indicatorColor: Colors.greenAccent,
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedType,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 6),
                ),
                alignment: Alignment.center,
                child: Text(
                  formatTime(remainingSeconds),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              IconButton(
                icon: Icon(
                  isRunning ? Icons.pause_circle : Icons.play_circle,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: toggleTimer,
              ),
              const SizedBox(height: 20),
              const SongCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class SongCard extends StatelessWidget {
  const SongCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: ListTile(
        leading: const Icon(Icons.music_note),
        title: const Text('Lofi Chill Beats'),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {},
        ),
      ),
    );
  }
}

class TimerSettingsModal extends StatelessWidget {
  const TimerSettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                labelColor: Colors.white,
                indicatorColor: Colors.greenAccent,
                tabs: [
                  Tab(icon: Icon(Icons.all_inclusive), text: 'Infinite Play'),
                  Tab(icon: Icon(Icons.timer), text: 'Set Timer'),
                  Tab(icon: Icon(Icons.loop), text: 'Set Interval'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Infinite Play
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Activate Quotes", style: TextStyle(color: Colors.white70)),
                        Switch(value: true, onChanged: (_) {}),
                        const SizedBox(height: 10),
                        const Text("Quote refresh cycle: 25:00", style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 30),
                        ElevatedButton(onPressed: () {}, child: const Text("APPLY"))
                      ],
                    ),
                    // Set Timer
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Choose your timer", style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          children: [
                            ElevatedButton(onPressed: () {}, child: const Text("5 min")),
                            ElevatedButton(onPressed: () {}, child: const Text("10 min")),
                            ElevatedButton(onPressed: () {}, child: const Text("15 min")),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Custom (mins)",
                              filled: true,
                              fillColor: Colors.white10,
                              hintStyle: TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(onPressed: () {}, child: const Text("APPLY"))
                      ],
                    ),
                    // Set Interval
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Work Time", style: TextStyle(color: Colors.white)),
                        Wrap(
                          spacing: 12,
                          children: [
                            ElevatedButton(onPressed: () {}, child: const Text("20 min")),
                            ElevatedButton(onPressed: () {}, child: const Text("25 min")),
                            ElevatedButton(onPressed: () {}, child: const Text("30 min")),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Rest Time", style: TextStyle(color: Colors.white)),
                        Wrap(
                          spacing: 12,
                          children: [
                            ElevatedButton(onPressed: () {}, child: const Text("5 min")),
                            ElevatedButton(onPressed: () {}, child: const Text("10 min")),
                            ElevatedButton(onPressed: () {}, child: const Text("15 min")),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(onPressed: () {}, child: const Text("APPLY"))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenderSelectionScreen extends StatelessWidget {
  const GenderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              "What's your gender?",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(
                "This will help us tailor your workout to match your metabolic rate perfectly",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Image.asset('assets/image copy.png', height: 180),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Male selected")),
                        );
                      },
                      child: const Text('Male'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image copy 2.png', height: 180),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Female selected")),
                        );
                      },
                      child: const Text('Female'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title Screen', style: const TextStyle(fontSize: 24)));
  }
}
