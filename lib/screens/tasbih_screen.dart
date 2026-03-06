import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tasbih_provider.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  // বিল্ট-ইন জিকির লিস্ট
  final List<Map<String, dynamic>> builtInDhikr = const [
    {'name': 'SubhanAllah', 'target': 33},
    {'name': 'Alhamdulillah', 'target': 33},
    {'name': 'Allahu Akbar', 'target': 34},
    {'name': 'La Ilaha Illallah', 'target': 100},
    {'name': 'Astaghfirullah', 'target': 100},
    {'name': 'SubhanAllahi Wa Bihamdihi', 'target': 100},
  ];

  @override
  Widget build(BuildContext context) {
    final tasbih = Provider.of<TasbihProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text("Digital Tasbih", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // জিকির সিলেকশন লিস্ট (Horizontal)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: builtInDhikr.length,
              itemBuilder: (context, index) {
                final item = builtInDhikr[index];
                bool isSelected = tasbih.selectedDhikr == item['name'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ActionChip(
                    backgroundColor: isSelected ? const Color(0xFFC5A059) : Colors.white,
                    label: Text(item['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                    onPressed: () => tasbih.setDhikr(item['name'], item['target']),
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          // কাউন্টার ডিসপ্লে এবং মেইন বাটন (আগের গোল ডিজাইন)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC5A059), width: 8),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                  ),
                ),
                GestureDetector(
                  onTap: () => tasbih.increment(),
                  child: Container(
                    width: 240, height: 240,
                    decoration: const BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tasbih.selectedDhikr, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        Text("${tasbih.count}", style: const TextStyle(fontSize: 75, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(tasbih.target == 0 ? "Unlimited" : "Target: ${tasbih.target}", style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // নিচের বাটনগুলো (Target & Reset)
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bottomAction(Icons.refresh, "Reset", () => tasbih.reset(), Colors.redAccent),
                _bottomAction(Icons.track_changes, "Change Target", () {
                  // টার্গেট বদলানোর জন্য ছোট অপশন
                  _showTargetMenu(context, tasbih);
                }, const Color(0xFF1B5E20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAction(IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showTargetMenu(BuildContext context, TasbihProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text("Set Target: 33"), onTap: () { provider.setOnlyTarget(33); Navigator.pop(context); }),
          ListTile(title: const Text("Set Target: 100"), onTap: () { provider.setOnlyTarget(100); Navigator.pop(context); }),
          ListTile(title: const Text("Set Target: Unlimited (∞)"), onTap: () { provider.setOnlyTarget(0); Navigator.pop(context); }),
        ],
      ),
    );
  }
}