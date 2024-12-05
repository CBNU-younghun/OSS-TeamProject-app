// utils/CrabAnimation.dart

import 'dart:async';
import 'package:flutter/material.dart';

class CrabAnimation extends StatefulWidget {
  @override
  _CrabAnimationState createState() => _CrabAnimationState();
}

class _CrabAnimationState extends State<CrabAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  List<String> crabImages = [
    'assets/ester egg/crab1.png',
    'assets/ester egg/crab2.png',
    'assets/ester egg/crab3.png',
    'assets/ester egg/crab4.png',
    'assets/ester egg/crab5.png',
  ];
  int _currentImageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 게가 앱의 가장자리를 따라 이동하도록 위치 설정
    List<Offset> positions = [
      Offset(-0.1, 0.0),  // 왼쪽 중간
      Offset(1.0, 0.0),   // 오른쪽 중간
      Offset(1.0, 1.0),   // 오른쪽 아래
      Offset(0.0, 1.0),   // 왼쪽 아래
      Offset(0.0, -0.1),  // 왼쪽 위
      Offset(-0.1, 0.0),  // 왼쪽 중간 (초기 위치)
    ];

    _controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );

    _animation = TweenSequence<Offset>([
      for (int i = 0; i < positions.length - 1; i++)
        TweenSequenceItem(
          tween: Tween<Offset>(
            begin: positions[i],
            end: positions[i + 1],
          ).chain(CurveTween(curve: Curves.linear)),
          weight: 1,
        ),
    ]).animate(_controller);

    _controller.repeat();

    // 이미지 변경을 위한 타이머 설정
    _timer = Timer.periodic(Duration(milliseconds: 200), (Timer timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % crabImages.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SlideTransition(
        position: _animation,
        child: Image.asset(
          crabImages[_currentImageIndex],
          width: 80,
          height: 80,
        ),
      ),
    );
  }
}
