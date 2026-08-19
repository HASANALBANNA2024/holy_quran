import 'dart:async';

import 'package:flutter/material.dart';

void showGuidanceOverlay({
  required BuildContext context,
  required String category,
  required String translation,
  required String surahName,
  required int ayahNumber,
  required VoidCallback onTap,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (context) {
      Timer(const Duration(seconds: 3), () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      });

      return Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.green, thickness: 1),
                const SizedBox(height: 15),
                Text(
                  "\"$translation\"",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                    fontFamily: 'Translation',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Surah $surahName : Ayah $ayahNumber",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Please click to read details",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
