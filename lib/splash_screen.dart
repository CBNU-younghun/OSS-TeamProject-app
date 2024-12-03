// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main.dart'; // main.dart 파일 경로에 맞게 수정하세요

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // 비디오 컨트롤러 초기화
    _controller = VideoPlayerController.asset('assets/intro_video.mp4')
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });

    // 비디오 재생이 완료되면 다음 화면으로 이동
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 다음 화면으로 이동하는 함수
  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => InitialScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialized
          ? Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
