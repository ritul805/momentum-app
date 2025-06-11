// Full integrated Flutter code with Pomodoro + Gender Selection + Move Screen + Yoga Navigation

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
    const Placeholder(), // will be replaced dynamically
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
        onTap: (index) async {
          if (index == 1) {
            final selectedGender = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (_) => const GenderSelectionScreen()),
            );
            if (selectedGender != null) {
              setState(() {
                _screens[1] = MoveScreen(gender: selectedGender);
                _currentIndex = 1;
              });
            }
          } else {
            setState(() => _currentIndex = index);
          }
        },
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Custom (mins)",
                              filled: true,
                              fillColor: Colors.white10,
                              hintStyle: TextStyle(color: Colors.white54),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.white),
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

// ---------------- GENDER SELECTION SCREEN ----------------

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
                        Navigator.pop(context, 'male');
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
                        Navigator.pop(context, 'female');
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

// ---------------- MOVE SCREEN ----------------

class MoveScreen extends StatelessWidget {
  final String gender;
  const MoveScreen({super.key, required this.gender});

  @override
  Widget build(BuildContext context) {
    final workouts = gender == 'male'
        ? [
            {'title': 'Yoga', 'desc': 'Deepen your practice through traditional yoga flows', 'img': 'assets/image copy 3.png'},
            {'title': 'Cardio and HIIT', 'desc': 'Build endurance with HIIT training', 'img': 'assets/image copy 4.png'},
            {'title': 'Combination', 'desc': 'Mix of yoga and cardio', 'img': 'assets/image copy 5.png'},
          ]
        : [
            {'title': 'Yoga', 'desc': 'Deepen your practice through traditional yoga flows', 'img': 'assets/image copy 8.png'},
            {'title': 'Cardio and HIIT', 'desc': 'Build endurance with HIIT training', 'img': 'assets/image copy 7.png'},
            {'title': 'Combination', 'desc': 'Mix of yoga and cardio', 'img': 'assets/image copy 8.png'},
          ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('For ${gender[0].toUpperCase()}${gender.substring(1)}', 
          style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: workouts
            .map((w) => GestureDetector(
                  onTap: () {
                    // Navigate to yoga screen when yoga is tapped
                    if (w['title'] == 'Yoga') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YogaBeginnersScreen(),
                        ),
                      );
                    }
                    // Add navigation for other workout types here
                  },
                  child: Card(
                    color: Colors.grey[900],
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          w['img']!, 
                          height: 200, 
                          width: double.infinity, 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.white54, size: 50),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(w['title']!, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(w['desc']!, style: const TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ---------------- YOGA BEGINNERS SCREEN ----------------

class YogaBeginnersScreen extends StatelessWidget {
  const YogaBeginnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final yogaVideos = [
      {
        'title': 'Beginner 10-minute Yoga',
        'subtitle': 'Best for stress relief',
        'duration': '10:00',
        'instructor': 'Yoga Singh',
        'img': 'assets/image copy 9.png',
      },
      {
        'title': 'Breathing work for relaxation',
        'subtitle': 'Focus on mindfulness',
        'duration': '8:30',
        'instructor': 'Yoga Singh',
        'img': 'assets/image copy 10.png',
      },
      {
        'title': 'Stretching a muscle during work',
        'subtitle': 'Quick desk stretches',
        'duration': '5:15',
        'instructor': 'Yoga Singh',
        'img': 'assets/image copy 11.png',
      },
      {
        'title': 'Boost the circulation of blood in your body',
        'subtitle': 'Energy boosting flow',
        'duration': '12:45',
        'instructor': 'Yoga Singh',
        'img': 'assets/image copy 12.png',
      },
      {
        'title': 'Stretching in the right form',
        'subtitle': 'Proper form techniques',
        'duration': '15:20',
        'instructor': 'Yoga Singh',
        'img': 'assets/image copy 13.png',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Icon(Icons.favorite_border, color: Colors.white),
                      const SizedBox(width: 16),
                      const Icon(Icons.share, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'BEGINNERS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '10-Minute Yoga For Beginners |\nStart Yoga Here...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'by Yoga Singh',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'A 10-minute beginner-friendly yoga class for those who are new to yoga or want to get back into it.'
                    ,style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Video List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: yogaVideos.length,
                itemBuilder: (context, index) {
                  final video = yogaVideos[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        video['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            video['duration']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.more_vert,
                        color: Colors.white54,
                      ),
                      onTap: () {
                        // Handle video tap - you can add video player navigation here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Playing: ${video['title']}'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Navigation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.home, 'Home', true),
                  _buildBottomNavItem(Icons.fitness_center, 'Fitness', false),
                  _buildBottomNavItem(Icons.library_books, 'Library', false),
                  _buildBottomNavItem(Icons.person, 'Profile', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.orange : Colors.white54,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.orange : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
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