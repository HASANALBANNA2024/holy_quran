import 'package:flutter/material.dart';

class ArabicText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final Color color;

  const ArabicText({
    super.key,
    required this.text,
    this.fontSize = 28,
    this.textAlign = TextAlign.right,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'QuranFont', // আপনার yaml ফাইলে দেওয়া নাম
        fontSize: fontSize,
        height: 1.8,
        color: color,
      ),
    );
  }
}