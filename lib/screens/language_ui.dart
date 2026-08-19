import 'package:flutter/material.dart';
import 'package:holy_quran/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../providers/quran_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);
    final languages = quranProvider.supportedLanguages;

    return Scaffold(
      appBar: AppBar(title: const Text("Translation Language")),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          String code = languages[index]['code']!;
          String name = languages[index]['name']!;

          return ListTile(
            title: Text(name),
            trailing: quranProvider.currentLang == code
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              await quranProvider.changeLanguage(code);
              if (!context.mounted) return;
              if (context.mounted) Navigator.pop(context);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Translation changed to $name")),
              );
            },
          );
        },
      ),
    );
  }
}
