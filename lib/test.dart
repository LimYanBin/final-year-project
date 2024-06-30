import 'package:flutter/material.dart';
import 'dart:math';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onIconPressed() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reset();
    }
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 218, 74, 122).withOpacity(0.3),
            Color.fromARGB(255, 139, 13, 55).withOpacity(0.5)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_controller.isAnimating)
                ...List.generate(5, (index) {
                  final angle = (index * 72) * (pi / 180);
                  return Transform.translate(
                    offset: Offset(
                      _animation.value * 100 * cos(angle),
                      _animation.value * 100 * sin(angle),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.primaries[index % Colors.primaries.length]
                          .withOpacity(1.0 - _animation.value),
                      size: 30 * (1.0 - _animation.value),
                    ),
                  );
                }),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite),
                    iconSize: 150,
                    color: Color.fromARGB(255, 236, 76, 129),
                    onPressed: _onIconPressed,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '笨蛋小曾',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
