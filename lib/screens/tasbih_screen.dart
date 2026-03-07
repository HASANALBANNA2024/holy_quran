import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/tasbih_provider.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  late ScrollController _autoScrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _autoScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_autoScrollController.hasClients) {
        double maxScroll = _autoScrollController.position.maxScrollExtent;
        double currentScroll = _autoScrollController.offset;
        double nextScroll = currentScroll + 120;
        if (nextScroll >= maxScroll) nextScroll = 0;

        _autoScrollController.animateTo(
          nextScroll,
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasbih = context.watch<TasbihProvider>();
    bool isCompleted = tasbih.target > 0 && tasbih.count == tasbih.target;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text("Digital Tasbih", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ✅ Islamic Vibe Background Icon
          const Center(
            child: Opacity(
              opacity: 0.04,
              child: Icon(Icons.mosque, size: 400, color: Colors.green),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 15),
              // ✅ Animated Scrolling Short Names
              SizedBox(
                height: 55,
                child: ListView.builder(
                  controller: _autoScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: tasbih.builtInDhikr.length,
                  itemBuilder: (context, index) {
                    final item = tasbih.builtInDhikr[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ActionChip(
                        backgroundColor: Colors.white,
                        label: Text(item['short'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                        onPressed: () => tasbih.setDhikr(item['full'], item['target']),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // ✅ Full Dhikr Display Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                height: 100,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Text(
                    tasbih.selectedDhikr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), height: 1.4),
                  ),
                ),
              ),

              const Spacer(),

              // ✅ Counter UI (Color Changes on Complete)
              GestureDetector(
                onTap: () => tasbih.increment(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 285, height: 285,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: isCompleted ? Colors.redAccent.withOpacity(0.4) : const Color(0xFFC5A059),
                            width: 10
                        ),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 245, height: 245,
                      decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFFD32F2F) : const Color(0xFF1B5E20),
                          shape: BoxShape.circle
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${tasbih.count}", style: const TextStyle(fontSize: 90, color: Colors.white, fontWeight: FontWeight.bold)),
                          // ✅ Inside Target Text
                          Text(
                            isCompleted ? "Completed!" : (tasbih.target == 0 ? "Unlimited" : "Target: ${tasbih.target}"),
                            style: TextStyle(
                                color: isCompleted ? Colors.white : Colors.white70,
                                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                                fontSize: 18
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Outside Message
              const SizedBox(height: 20),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isCompleted ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Text(
                    "MashaAllah! Target Completed",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),

              const Spacer(),

              // ✅ Bottom Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 45),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bottomBtn(Icons.refresh, "Reset", Colors.redAccent, () => tasbih.reset()),
                    const SizedBox(width: 60),
                    _bottomBtn(Icons.tune, "Custom", const Color(0xFF1B5E20), () => _showCustomSetup(context, tasbih)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color, radius: 28, child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ✅ Custom Setup (Empty Fields & Quick Select)
  void _showCustomSetup(BuildContext context, TasbihProvider provider) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Custom Counter Setup", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            const SizedBox(height: 25),

            const Text("Quick Select Dhikr:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: provider.builtInDhikr.map((d) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(d['short']),
                    onPressed: () => nameCtrl.text = d['full'],
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                )).toList(),
              ),
            ),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Dhikr / Doa Name", hintText: "Write your doa")),

            const SizedBox(height: 25),

            const Text("Quick Select Target:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [33, 34, 100, 1000].map((t) => ActionChip(
                label: Text(t.toString()),
                onPressed: () => targetCtrl.text = t.toString(),
                backgroundColor: const Color(0xFFC5A059).withOpacity(0.2),
              )).toList(),
            ),
            TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target Number", hintText: "Set target")),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                String finalName = nameCtrl.text.isEmpty ? provider.selectedDhikr : nameCtrl.text;
                int finalTarget = int.tryParse(targetCtrl.text) ?? provider.target;
                provider.setDhikr(finalName, finalTarget);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}