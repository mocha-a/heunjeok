import 'dart:ui';
import 'package:flutter/material.dart';

class CoverImage extends StatelessWidget {
  final String imagePath;
  final double height;

  const CoverImage({
    Key? key,
    required this.imagePath,
    this.height = 380, // 기본값 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 이미지
        Container(
          width: double.infinity,
          height: height,
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
        // 배경 이미지 블러 처리
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        // 커버 이미지
        Positioned.fill(
          child: Center(
            child: Image.asset(
              imagePath,
              height: height - 80, // 조절 가능
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
