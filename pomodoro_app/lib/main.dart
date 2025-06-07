import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro App',
      theme: ThemeData.dark(),
      home: const PomodoroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with TickerProviderStateMixin {
  final List<String> timerTypes = ["Focus", "Short Break", "Long Break"];
  final Map<String, int> timerDurations = {
    "Focus": 1500,
    "Short Break": 300,
    "Long Break": 900,
  };

  late String selectedTimerType;
  late int remainingSeconds;
  Timer? _timer;
  bool isRunning = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    selectedTimerType = "Focus";
    remainingSeconds = timerDurations[selectedTimerType]!;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        selectedTimerType = timerTypes[_tabController.index];
        remainingSeconds = timerDurations[selectedTimerType]!;
        _timer?.cancel();
        isRunning = false;
      });
    });
  }

  void toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            _timer?.cancel();
            isRunning = false;
          }
        });
      });
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "$minutes:${secs.toString().padLeft(2, '0')}";
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
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text("Pomodoro"),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const HamburgerModal(),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: timerTypes.map((type) => Tab(text: type)).toList(),
              indicatorColor: Colors.greenAccent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedTimerType,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 6),
                ),
                child: Text(
                  formatTime(remainingSeconds),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              IconButton(
                icon: Icon(isRunning ? Icons.pause_circle : Icons.play_circle, size: 64),
                onPressed: toggleTimer,
              ),
              const SizedBox(height: 40),
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
        title: const Text("Lofi Chill Beats"),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            // Add play logic here
          },
        ),
      ),
    );
  }
}

class HamburgerModal extends StatelessWidget {
  const HamburgerModal({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: const [
              TabBar(
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
                    InfinitePlayTab(),
                    SetTimerTab(),
                    SetIntervalTab(),
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

class InfinitePlayTab extends StatelessWidget {
  const InfinitePlayTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Infinite Play Settings", style: TextStyle(color: Colors.white)));
  }
}

class SetTimerTab extends StatelessWidget {
  const SetTimerTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Set Timer Settings", style: TextStyle(color: Colors.white)));
  }
}

class SetIntervalTab extends StatelessWidget {
  const SetIntervalTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Set Interval Settings", style: TextStyle(color: Colors.white)));
  }
}
