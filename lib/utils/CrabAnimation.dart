import 'dart:async';
import 'dart:math';
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

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 초기 애니메이션 설정
    _setRandomAnimation();

    // 애니메이션이 완료되면 새로운 랜덤 위치로 이동
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _setRandomAnimation();
      }
    });

    // 이미지 변경 타이머 설정
    _timer = Timer.periodic(Duration(milliseconds: 200), (Timer timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % crabImages.length;
      });
    });
  }

  void _setRandomAnimation() {
    // 랜덤한 종료 위치 설정
    double randomX = _random.nextDouble() * 2 - 1; // -1.0 ~ 1.0 사이의 값
    double randomY = _random.nextDouble() * 2 - 1; // -1.0 ~ 1.0 사이의 값

    setState(() {
      _animation = Tween<Offset>(
        begin: _animation.value,
        end: Offset(randomX, randomY),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    });

    // 애니메이션 시작
    _controller.reset();
    _controller.forward();
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
