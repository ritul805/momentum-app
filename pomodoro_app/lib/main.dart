import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
    const MomentumHomeScreen(),
    const ProfileScreen(), // Updated from placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
                    if (w['title'] == 'Yoga') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YogaBeginnersScreen(),
                        ),
                      );
                    }
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

// ---------------- YOGA BEGINNERS SCREEN WITH YOUTUBE PLAYER ----------------


class YogaBeginnersScreen extends StatefulWidget {
  const YogaBeginnersScreen({super.key});

  @override
  State<YogaBeginnersScreen> createState() => _YogaBeginnersScreenState();
}

class _YogaBeginnersScreenState extends State<YogaBeginnersScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  final yogaVideos = [
    {
      'title': 'Beginner 10-minute Yoga',
      'subtitle': 'Best for stress relief',
      'duration': '10:00',
      'instructor': 'Yoga Singh',
      'videoId': 'v7AYKMP6rOE',
    },
    {
      'title': 'Breathing work for relaxation',
      'subtitle': 'Focus on mindfulness',
      'duration': '8:30',
      'instructor': 'Yoga Singh',
      'videoId': 'inpok4MKVLM',
    },
    {
      'title': 'Stretching a muscle during work',
      'subtitle': 'Quick desk stretches',
      'duration': '5:15',
      'instructor': 'Yoga Singh',
      'videoId': 'RqcOCBb4arc',
    },
    {
      'title': 'Boost the circulation of blood in your body',
      'subtitle': 'Energy boosting flow',
      'duration': '12:45',
      'instructor': 'Yoga Singh',
      'videoId': 'Eml2xnoLpYE',
    },
    {
      'title': 'Stretching in the right form',
      'subtitle': 'Proper form techniques',
      'duration': '15:20',
      'instructor': 'Yoga Singh',
      'videoId': 'sTANio_2E0Q',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: yogaVideos[0]['videoId']!,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        enableCaption: true,
      ),
    )..addListener(listener);
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playVideo(String videoId, String title) {
    _controller.load(videoId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Now playing: $title'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.orange,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video completed! Great job! 🧘‍♀️'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
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
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to favorites! ❤️'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sharing yoga session! 📤'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A 10-minute beginner-friendly yoga class for those who are new to yoga or want to get back into it.',
                      style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: player,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: yogaVideos.length,
                  itemBuilder: (context, index) {
                    final video = yogaVideos[index];
                    final isCurrentVideo = _controller.metadata.videoId == video['videoId'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isCurrentVideo ? Colors.orange.withOpacity(0.2) : Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrentVideo
                            ? Border.all(color: Colors.orange, width: 2)
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isCurrentVideo
                                ? Colors.orange.withOpacity(0.3)
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isCurrentVideo ? Icons.play_circle : Icons.play_circle_outline,
                            color: isCurrentVideo ? Colors.orange : Colors.white,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          video['title']!,
                          style: TextStyle(
                            color: isCurrentVideo ? Colors.orange : Colors.white,
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
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              video['duration']!,
                              style: TextStyle(
                                color: isCurrentVideo ? Colors.orange : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.more_vert,
                          color: isCurrentVideo ? Colors.orange : Colors.white54,
                        ),
                        onTap: () => _playVideo(video['videoId']!, video['title']!),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ---------------- MOMENTUM HOME SCREEN (LEARN TAB) ----------------

class MomentumPost {
  final String title;
  final String description;
  final String imageUrl;
  final String category;

  MomentumPost({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
  });
}

class MomentumHomeScreen extends StatefulWidget {
  const MomentumHomeScreen({super.key});

  @override
  State<MomentumHomeScreen> createState() => _MomentumHomeScreenState();
}

class _MomentumHomeScreenState extends State<MomentumHomeScreen> {
  String selectedCategory = 'Popular Posts';
  
  final List<String> categories = [
    'Popular Posts',
    'New Posts',
    'Trendy Posts'
  ];

  final List<MomentumPost> posts = [
    MomentumPost(
      title: 'Opening Day Of Boating Season',
      description: 'Of Course The Puget Sound Is Very Wintery But Whole Truth Is Winter, There Are Some Good Summer Days, Followed By...',
      imageUrl: 'assets/image copy 14.png',
      category: 'Popular Posts',
    ),
    MomentumPost(
      title: '12 Mobile UX Design Trends For 2025',
      description: 'New Ideas Include In The Vector Art Designs For Latest UX Experience This Year & More...',
      imageUrl: 'assets/image copy 15.png',
      category: 'New Posts',
    ),
    MomentumPost(
      title: 'How To Build A Self-Driving Car In Only 6 Months',
      description: 'Don\'t Underestimate Computer Science Abilities From Big AI Smart Cars Advancement and Machine Learning...',
      imageUrl: 'assets/image copy 16.png',
      category: 'Trendy Posts',
    ),
    MomentumPost(
      title: 'India Has Been Selected To Host The World Boxing Cup Final',
      description: 'India has been selected to host The World Boxing Cup Final And The World Championship Tournament in November 2025...',
      imageUrl: 'assets/image copy 17.png',
      category: 'Popular Posts',
    ),
    MomentumPost(
      title: 'AI Revolution in Healthcare 2025',
      description: 'Revolutionary AI applications are transforming healthcare delivery with precision medicine and diagnostic tools...',
      imageUrl: 'assets/ai copy.png',
      category: 'New Posts',
    ),
    MomentumPost(
      title: 'Sustainable Energy Solutions',
      description: 'Latest breakthrough in renewable energy technology promises cleaner future with innovative solar panel designs...',
      imageUrl: 'assets/sus copy.jpg',
      category: 'Trendy Posts',
    ),
  ];

  List<MomentumPost> get filteredPosts {
    return posts.where((post) => post.category == selectedCategory).toList();
  }

  
@override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: SafeArea(

        child: Column(

          children: [

            // Header

            Padding(

              padding: const EdgeInsets.all(16.0),

              child: Row(

                children: [

                  // Menu Icon

                  Container(

                    width: 40,

                    height: 40,

                    decoration: BoxDecoration(

                      color: Colors.grey[900],

                      borderRadius: BorderRadius.circular(8),

                    ),

                    child: const Icon(

                      Icons.menu,

                      color: Colors.white,

                      size: 20,

                    ),

                  ),

                  const Spacer(),

                  // Search Bar

                  Expanded(

                    flex: 3,

                    child: Container(

                      height: 40,

                      decoration: BoxDecoration(

                        color: Colors.grey[900],

                        borderRadius: BorderRadius.circular(20),

                      ),

                      child: TextField(

                        style: const TextStyle(color: Colors.white),

                        decoration: InputDecoration(

                          hintText: 'Search anything...',

                          hintStyle: TextStyle(color: Colors.grey[400]),

                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),

                          border: InputBorder.none,

                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                        ),

                      ),

                    ),

                  ),

                  const Spacer(),

                  // Profile Icon

                  const CircleAvatar(

                    radius: 20,

                    backgroundColor: Colors.blue,

                    child: Text(

                      'M',

                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),

                    ),

                  ),

                ],

              ),

            ),

            

            // Category Tabs

            Container(

              height: 50,

              margin: const EdgeInsets.symmetric(horizontal: 16),

              child: ListView.builder(

                scrollDirection: Axis.horizontal,

                itemCount: categories.length,

                itemBuilder: (context, index) {

                  final category = categories[index];

                  final isSelected = category == selectedCategory;

                  

                  return GestureDetector(

                    onTap: () {

                      setState(() {

                        selectedCategory = category;

                      });

                    },

                    child: Container(

                      margin: const EdgeInsets.only(right: 12),

                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

                      decoration: BoxDecoration(

                        color: isSelected ? Colors.blue : Colors.grey[900],

                        borderRadius: BorderRadius.circular(25),

                      ),

                      child: Text(

                        category,

                        style: TextStyle(

                          color: isSelected ? Colors.white : Colors.grey[400],

                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,

                        ),

                      ),

                    ),

                  );

                },

              ),

            ),

            

            // Posts List

            Expanded(

              child: ListView.builder(

                padding: const EdgeInsets.all(16),

                itemCount: filteredPosts.length,

                itemBuilder: (context, index) {

                  final post = filteredPosts[index];

                  

                  return Container(

                    margin: const EdgeInsets.only(bottom: 16),

                    decoration: BoxDecoration(

                      color: Colors.grey[900],

                      borderRadius: BorderRadius.circular(12),

                    ),

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        // Image

                        ClipRRect(

                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),

                          child: Image.asset(

                            post.imageUrl,

                            height: 200,

                            width: double.infinity,

                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) {

                              return Container(

                                height: 200,

                                color: Colors.grey[800],

                                child: Icon(

                                  Icons.image_not_supported,

                                  color: Colors.grey[600],

                                  size: 50,

                                ),

                              );

                            },

                          ),

                        ),

                        

                        // Content

                        Padding(

                          padding: const EdgeInsets.all(16),

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(

                                post.title,

                                style: const TextStyle(

                                  color: Colors.white,

                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,

                                ),

                              ),

                              const SizedBox(height: 8),

                              Text(

                                post.description,

                                style: TextStyle(

                                  color: Colors.grey[400],

                                  fontSize: 14,

                                  height: 1.4,

                                ),

                                maxLines: 3,

                                overflow: TextOverflow.ellipsis,

                              ),

                              const SizedBox(height: 12),

                              Row(

                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: [

                                  Container(

                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                                    decoration: BoxDecoration(

                                      // ignore: deprecated_member_use

                                      color: Colors.blue.withOpacity(0.2),

                                      borderRadius: BorderRadius.circular(4),

                                    ),

                                    child: Text(

                                      post.category,

                                      style: const TextStyle(

                                        color: Colors.blue,

                                        fontSize: 12,

                                      ),

                                    ),

                                  ),

                                  Row(

                                    children: [

                                      Icon(Icons.favorite_border, color: Colors.grey[400], size: 18),

                                      const SizedBox(width: 8),

                                      Icon(Icons.share, color: Colors.grey[400], size: 18),

                                      const SizedBox(width: 8),

                                      Icon(Icons.bookmark_border, color: Colors.grey[400], size: 18),

                                    ],

                                  ),

                                ],

                              ),

                            ],

                          ),

                        ),

                      ],

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {

    return Column(

      mainAxisAlignment: MainAxisAlignment.center,

      children: [

        Icon(

          icon,

          color: isActive ? Colors.blue : Colors.grey[400],

          size: 24,

        ),

        // ignore: prefer_const_constructors

        const SizedBox(height: 4),

        Text(

          label,

          style: TextStyle(

            color: isActive ? Colors.blue : Colors.grey[400],

            fontSize: 12,

            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,

          ),

        ),

      ],

    );

  }

}

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: SafeArea(

        child: Column(

          children: [

            // Header with back button and menu

            Padding(

              padding: const EdgeInsets.all(16.0),

              child: Row(

                children: [

                  IconButton(

                    icon: const Icon(Icons.arrow_back, color: Colors.white),

                    onPressed: () {

                      // Handle back navigation if needed

                    },

                  ),

                  const Spacer(),

                  IconButton(

                    icon: const Icon(Icons.more_vert, color: Colors.white),

                    onPressed: () {

                      // Handle menu options

                    },

                  ),

                ],

              ),

            ),

            // Profile Section

            Expanded(

              child: SingleChildScrollView(

                child: Column(

                  children: [

                    // Profile Picture and Name

                    const CircleAvatar(

                      radius: 50,

                      backgroundColor: Colors.white,

                      child: Icon(

                        Icons.person,

                        size: 60,

                        color: Colors.black,

                      ),

                    ),

                    const SizedBox(height: 16),

                    const Text(

                      'Anupam Singh',

                      style: TextStyle(

                        color: Colors.white,

                        fontSize: 24,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 4),

                    TextButton(

                      onPressed: () {

                        // Handle edit profile

                      },

                      child: const Text(

                        'Edit Profile',

                        style: TextStyle(

                          color: Colors.grey,

                          fontSize: 14,

                        ),

                      ),

                    ),

                    const SizedBox(height: 24),

                    // Stats Row

                    Row(

                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                      children: [

                        _buildStatItem(Icons.analytics, 'Progress'),

                        _buildStatItem(Icons.settings, 'Settings'),

                      ],

                    ),

                    const SizedBox(height: 32),

                    // Inbox Section

                    Container(

                      width: double.infinity,

                      margin: const EdgeInsets.symmetric(horizontal: 16),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(

                        color: Colors.grey[900],

                        borderRadius: BorderRadius.circular(12),

                      ),

                      child: Row(

                        children: [

                          const Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(

                                'Inbox',

                                style: TextStyle(

                                  color: Colors.white,

                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,

                                ),

                              ),

                              Text(

                                'View Messages',

                                style: TextStyle(

                                  color: Colors.grey,

                                  fontSize: 14,

                                ),

                              ),

                            ],

                          ),

                          const Spacer(),

                          IconButton(

                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),

                            onPressed: () {

                              // Handle inbox navigation

                            },

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 24),

                    // Friends Section

                    Container(

                      width: double.infinity,

                      margin: const EdgeInsets.symmetric(horizontal: 16),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(

                        color: Colors.grey[900],

                        borderRadius: BorderRadius.circular(12),

                      ),

                      child: const Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(

                            'FRIENDS',

                            style: TextStyle(

                              color: Colors.white,

                              fontSize: 16,

                              fontWeight: FontWeight.bold,

                              letterSpacing: 1.2,

                            ),

                          ),

                          SizedBox(height: 16),

                          Text(

                            'Member Since April 2025',

                            style: TextStyle(

                              color: Colors.grey,

                              fontSize: 12,

                            ),

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 100), // Space for bottom navigation

                  ],

                ),

              ),

            ),

          ],

        ),

      ),

      // Bottom Navigation Bar

      

    );

  }



  Widget _buildStatItem(IconData icon, String label) {

    return Column(

      children: [

        Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            color: Colors.grey[900],

            borderRadius: BorderRadius.circular(12),

          ),

          child: Icon(

            icon,

            color: Colors.white,

            size: 24,

          ),

        ),

        const SizedBox(height: 8),

        Text(

          label,

          style: const TextStyle(

            color: Colors.white,

            fontSize: 12,

          ),

        ),

      ],

    );

  }



  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {

    return Column(

      mainAxisSize: MainAxisSize.min,

      children: [

        Icon(

          icon,

          color: isSelected ? Colors.green : Colors.grey,

          size: 24,

        ),

        const SizedBox(height: 4),

        Text(

          label,

          style: TextStyle(

            color: isSelected ? Colors.green : Colors.grey,

            fontSize: 12,

          ),

        ),

      ],

    );

  }

}


