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
      title: 'Pomodoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PomodoroScreen(),
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
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
        // Translucent background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Pomodoro'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const TimerSettingsModal(),
                  );
                },
              )
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: timerTypes.map((e) => Tab(text: e)).toList(),
              indicatorColor: Colors.greenAccent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 8),
                ),
                alignment: Alignment.center,
                child: Text(
                  formatTime(remainingSeconds),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              IconButton(
                icon: Icon(
                  isRunning ? Icons.pause_circle : Icons.play_circle,
                  size: 48,
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

// TIMER SETTINGS MODAL
class TimerSettingsModal extends StatelessWidget {
  const TimerSettingsModal({super.key});

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

// Timer Setting Tabs
class InfinitePlayTab extends StatelessWidget {
  const InfinitePlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          value: true,
          onChanged: (_) {},
          title: const Text("Show Quotes", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 20),
        const Text("Default time: 25 min", style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class SetTimerTab extends StatelessWidget {
  const SetTimerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          children: [5, 10, 15].map((min) {
            return ElevatedButton(
              onPressed: () {},
              child: Text("$min min"),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Custom Time (minutes)",
            labelStyle: TextStyle(color: Colors.white),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            border: OutlineInputBorder(),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class SetIntervalTab extends StatelessWidget {
  const SetIntervalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Work/Rest Time", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [20, 25, 30].map((min) {
            return ElevatedButton(onPressed: () {}, child: Text("$min / 5"));
          }).toList(),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
          child: const Text("Apply"),
        ),
      ],
    );
  }
}
