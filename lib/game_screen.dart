import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class Egg {
  final double x;
  final double y;
  
  Egg(this.x, this.y);
}

class GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  double _chickenX = 0.5;
  double _chickenY = 0.5;
  int _score = 0;
  bool _isClicked = false;
  Timer? _moveTimer;
  Timer? _clickTimer;
  
  // List to store all eggs laid during the game
  List<Egg> _eggs = [];

  @override
  void initState() {
    super.initState();
    _startChickenMovement();
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _clickTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startChickenMovement() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      setState(() {
        _chickenX = _random.nextDouble() * 0.8 + 0.1; // Between 0.1 and 0.9
        _chickenY = _random.nextDouble() * 0.8 + 0.1; // Between 0.1 and 0.9
      });
    });
  }

  void _onChickenTap() async {
    print("Chicken clicked! Changing image and laying an egg...");
    
    // Add an egg at the current chicken position
    setState(() {
      _eggs.add(Egg(_chickenX, _chickenY));
      _isClicked = true;
      _score++;
    });

    // Play chicken sound
    await _audioPlayer.play(AssetSource('sounds/chicken_sound.mp3'));
    
    // Reset chicken appearance after a longer delay
    _clickTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isClicked = false;
        });
      }
    });

    // Check if player won
    if (_score >= 10) {
      _moveTimer?.cancel();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You caught the chicken 10 times! You win!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _score = 0;
                  _chickenX = 0.5;
                  _chickenY = 0.5;
                  _eggs = []; // Clear all eggs for the new game
                });
                _startChickenMovement();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chicken Farm'),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        decoration: const BoxDecoration(
          // If you have a background image, uncomment this:
          // image: DecorationImage(
          //   image: AssetImage('assets/images/farm_background.png'),
          //   fit: BoxFit.cover,
          // ),
          color: Color(0xFF8BC34A), // Light green background as fallback
        ),
        child: Stack(
          children: [
            // Score display
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Score: $_score / 10',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Eggs - render all eggs that have been laid
            ..._eggs.map((egg) => Positioned(
              left: egg.x * size.width - 15, // Center the egg
              top: egg.y * size.height - 15, // Center the egg
              child: Image.asset(
                'assets/images/egg.png',
                width: 30,
                height: 30,
              ),
            )),
            
            // Chicken with enhanced visual feedback
            Positioned(
              left: _chickenX * size.width - 50,
              top: _chickenY * size.height - 50,
              child: GestureDetector(
                onTap: _onChickenTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: _isClicked 
                      ? (Matrix4.identity()..scale(1.2))  // Make chicken bigger when clicked
                      : Matrix4.identity(),
                  child: Stack(
                    children: [
                      Image.asset(
                        _isClicked 
                            ? 'assets/images/chicken_clicked.png'
                            : 'assets/images/chicken_normal.png',
                        width: 100,
                        height: 100,
                      ),
                      if (_isClicked)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.5),
                                spreadRadius: 10,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Egg count display
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/egg.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_eggs.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
