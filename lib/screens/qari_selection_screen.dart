import 'package:flutter/material.dart';
import 'package:holy_quran/data/qari_data.dart';
import 'package:holy_quran/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../providers/qari_provider.dart';

class QariSelectionScreen extends StatelessWidget {
  const QariSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void returnToHome(BuildContext context) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Qari",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () => returnToHome(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          returnToHome(context);
        },
        child: ListView.separated(
          itemCount: QariData.qariList.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final qari = QariData.qariList[index];
            return Consumer<QariProvider>(
              builder: (context, provider, child) {
                bool isSelected = provider.selectedQariId == qari['id'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? const Color(0xFF1B5E20)
                        : Colors.grey[200],
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    qari['name']!,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF1B5E20)
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20))
                      : null,
                  onTap: () {
                    provider.updateQari(qari['id']!, qari['name']!);
                    returnToHome(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${qari['name']} Selected done!"),
                        duration: const Duration(milliseconds: 800),
                        backgroundColor: const Color(0xFF1B5E20),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
