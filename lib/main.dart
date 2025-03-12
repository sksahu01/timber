import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const TimberApp());
}

class TimberApp extends StatelessWidget {
  const TimberApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timber',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forest, size: 100, color: Colors.green[800]),
            const SizedBox(height: 20),
            const Text(
              'TIMBER',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[300]!, Colors.blue[600]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TIMBER',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 80),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('How to Play'),
                          content: const SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text(
                                  '1. Tap left or right side of the screen to chop in that direction',
                                ),
                                Text(
                                  '2. Time your chops with the branch positions',
                                ),
                                Text(
                                  '3. Score points for each successful chop',
                                ),
                                Text(
                                  '4. Game ends if you chop in the wrong direction',
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Got it!'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[500],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'HOW TO PLAY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int score = 0;
  bool isGameOver = false;
  int timeLeft = 60;
  Timer? gameTimer;
  late AnimationController _treeSwayController;

  // Game state
  bool isBranchLeft = false;
  bool isPlayerOnLeft = true;
  double playerYPosition = 0.7;

  // Log positions (relative height on screen)
  List<double> logPositions = [];
  int logCount = 10;

  @override
  void initState() {
    super.initState();

    // Initialize tree animation
    _treeSwayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initialize logs and first branch
    _initializeGame();

    // Start game timer
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          timeLeft--;
          if (timeLeft <= 0) {
            _endGame();
          }
        });
      }
    });
  }

  void _initializeGame() {
    // Generate initial logs
    logPositions = List.generate(logCount, (index) {
      return 0.9 - (index * 0.08);
    });

    // Initial branch direction (random)
    isBranchLeft = Random().nextBool();
  }

  void _chopTree(bool chopLeft) {
    if (isGameOver) return;

    setState(() {
      // Check if player chopped in the correct direction
      if (chopLeft != isBranchLeft) {
        // Correct chop!
        score++;

        // Move logs down
        for (int i = 0; i < logPositions.length; i++) {
          logPositions[i] += 0.08;
        }

        // Remove logs that went off screen and add new one at top
        while (logPositions.isNotEmpty && logPositions.last > 1.0) {
          logPositions.removeLast();
        }

        // Add new log at top
        if (logPositions.isNotEmpty) {
          logPositions.insert(0, logPositions.first - 0.08);
        }

        // Switch player position
        isPlayerOnLeft = !isPlayerOnLeft;

        // Generate new branch (randomly)
        isBranchLeft = Random().nextBool();
      } else {
        // Wrong direction - game over!
        _endGame();
      }
    });
  }

  void _endGame() {
    setState(() {
      isGameOver = true;
    });
    gameTimer?.cancel();
    _treeSwayController.stop();

    // Show game over dialog after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Game Over'),
              content: Text('Your score: $score'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Play Again'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                ),
                TextButton(
                  child: const Text('Main Menu'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _treeSwayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlue[300]!, Colors.blue[700]!],
              ),
            ),
          ),

          // Game elements
          Column(
            children: [
              // Score and timer
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.brown[700]!.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Score: $score',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              timeLeft < 10
                                  ? Colors.red.withOpacity(0.7)
                                  : Colors.brown[700]!.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Time: $timeLeft',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Game area
              Expanded(
                child: Stack(
                  children: [
                    // Tree trunk
                    Center(
                      child: AnimatedBuilder(
                        animation: _treeSwayController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: sin(_treeSwayController.value * pi) * 0.01,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 40,
                          height: double.infinity,
                          color: Colors.brown[800],
                        ),
                      ),
                    ),

                    // Logs
                    ...logPositions.map((yPosition) {
                      return Positioned(
                        left: 0,
                        right: 0,
                        top: MediaQuery.of(context).size.height * yPosition,
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.brown[600],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Branch
                    Positioned(
                      left: isBranchLeft ? 0 : null,
                      right: isBranchLeft ? null : 0,
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      top: MediaQuery.of(context).size.height * 0.4,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green[800],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    // Player (lumberjack)
                    Positioned(
                      left: isPlayerOnLeft ? 20 : null,
                      right: isPlayerOnLeft ? null : 20,
                      bottom:
                          MediaQuery.of(context).size.height *
                          (1 - playerYPosition),
                      child: Container(
                        width: 50,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.cyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 40,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.red[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tap areas (invisible)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _chopTree(true),
                            behavior: HitTestBehavior.opaque,
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _chopTree(false),
                            behavior: HitTestBehavior.opaque,
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Game over overlay
          if (isGameOver)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
