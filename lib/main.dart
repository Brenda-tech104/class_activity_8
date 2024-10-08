import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(HalloweenGame());
}

class HalloweenGame extends StatefulWidget {
  @override
  _HalloweenGameState createState() => _HalloweenGameState();
}

class _HalloweenGameState extends State<HalloweenGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer backgroundMusic;
  late AudioPlayer successSound;
  late AudioPlayer jumpScareSound;

  // Constants for item dimensions
  static const double itemSize = 50.0;
  static const int numberOfBats = 30;
  static const int numberOfPumpkins = 30;
  static const int numberOfGhosts = 30;

  // Define the images and include multiple instances for bats, pumpkins, and ghosts
  final List<String> items = [
    'candyCorrectItem.png',
    ...List.generate(numberOfBats, (_) => 'bats.png'),
    ...List.generate(numberOfPumpkins, (_) => 'pumpkin.png'),
    ...List.generate(numberOfGhosts, (_) => 'ghost.png'),
  ];

  String correctItem = 'candyCorrectItem.png'; // Set the correct item directly
  String message = '';
  bool isGameOver = false;
  bool gameStarted = false; // Track if the game has started

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat(reverse: true);
    backgroundMusic = AudioPlayer();
    successSound = AudioPlayer();
    jumpScareSound = AudioPlayer();
    loadSounds();
  }

  void loadSounds() async {
    await backgroundMusic
        .setSource(AssetSource('assets/sounds/background_music.mp3'));
    await successSound
        .setSource(AssetSource('assets/sounds/success_sound.mp3'));
    await jumpScareSound.setSource(AssetSource('assets/sounds/jump_scare.mp3'));

    // Set the release mode to loop the background music
    backgroundMusic.setReleaseMode(ReleaseMode.loop);
  }

  void startGame() {
    setState(() {
      gameStarted = true; // Game has started
      backgroundMusic.resume(); // Play background music
    });
  }

  void _onItemTapped(String item) {
    if (!gameStarted) return; // Prevent interaction until game starts

    if (item == correctItem) {
      setState(() {
        message = 'You Found It!';
        isGameOver = true;
      });
      successSound.resume(); // Play success sound
    } else {
      setState(() {
        message = 'Oh no! It\'s a trap!';
      });
      jumpScareSound.resume(); // Play jump scare sound
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    backgroundMusic.dispose();
    successSound.dispose();
    jumpScareSound.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Halloween Game')),
        body: Center(
          child: gameStarted
              ? Stack(
                  children: items.map((item) {
                    return AnimatedPositioned(
                      duration: Duration(seconds: 2),
                      top: Random().nextDouble() * 400,
                      left: Random().nextDouble() * 400,
                      child: GestureDetector(
                        onTap: () => _onItemTapped(item),
                        child: Image.asset(
                          'assets/images/$item', // Update this path based on your assets folder structure
                          width: itemSize,
                          height: itemSize,
                        ),
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to the Halloween Game!',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: startGame,
                      child: Text('Play'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
