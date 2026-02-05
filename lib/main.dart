import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/* ===================== APP ROOT ===================== */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(),
    );
  }
}

/* ===================== START SCREEN ===================== */

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MADE BY',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'BHUVAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SnakeGame()),
                );
              },
              child: const Text(
                'START GAME',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== GAME OVER SCREEN ===================== */

class GameOverScreen extends StatelessWidget {
  final int score;

  const GameOverScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.red,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'FINAL SCORE: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SnakeGame()),
                );
              },
              child: const Text(
                'RESTART',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== SNAKE GAME ===================== */

enum Direction { up, down, left, right }

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int rowCount = 20;
  static const int colCount = 20;

  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  Direction direction = Direction.right;
  Timer? timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    snake = [const Point(10, 10)];
    direction = Direction.right;
    score = 0;
    generateFood();

    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      moveSnake();
    });
  }

  void generateFood() {
    final rand = Random();
    food = Point(rand.nextInt(rowCount), rand.nextInt(colCount));
  }

  void moveSnake() {
    setState(() {
      final head = snake.first;
      Point<int> newHead;

      switch (direction) {
        case Direction.up:
          newHead = Point(head.x - 1, head.y);
          break;
        case Direction.down:
          newHead = Point(head.x + 1, head.y);
          break;
        case Direction.left:
          newHead = Point(head.x, head.y - 1);
          break;
        case Direction.right:
          newHead = Point(head.x, head.y + 1);
          break;
      }

      if (newHead.x < 0 ||
          newHead.y < 0 ||
          newHead.x >= rowCount ||
          newHead.y >= colCount ||
          snake.contains(newHead)) {
        timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameOverScreen(score: score),
          ),
        );
        return;
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        score += 10;
        generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void changeDirection(Direction newDir) {
    if ((direction == Direction.up && newDir == Direction.down) ||
        (direction == Direction.down && newDir == Direction.up) ||
        (direction == Direction.left && newDir == Direction.right) ||
        (direction == Direction.right && newDir == Direction.left)) {
      return;
    }
    direction = newDir;
  }

  Widget controlButton(IconData icon, Direction dir) {
    return IconButton(
      iconSize: 40,
      color: Colors.white,
      onPressed: () => changeDirection(dir),
      icon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Score: $score'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// PLAY AREA
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: colCount,
                ),
                itemCount: rowCount * colCount,
                itemBuilder: (context, index) {
                  final x = index ~/ colCount;
                  final y = index % colCount;
                  final point = Point(x, y);

                  Color color = Colors.black;
                  if (snake.contains(point)) {
                    color = Colors.green;
                  } else if (point == food) {
                    color = Colors.red;
                  }

                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
            ),
          ),

          /// SEPARATOR
          Container(height: 4, color: Colors.green),

          /// CONTROL AREA
          Container(
            color: Colors.blueGrey.shade900,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                controlButton(Icons.keyboard_arrow_up, Direction.up),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    controlButton(Icons.keyboard_arrow_left, Direction.left),
                    const SizedBox(width: 20),
                    controlButton(Icons.keyboard_arrow_right, Direction.right),
                  ],
                ),
                controlButton(Icons.keyboard_arrow_down, Direction.down),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
