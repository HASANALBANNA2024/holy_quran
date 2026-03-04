import 'package:flutter/material.dart';
import 'package:holy_quran/screens/bookmark_screen.dart';
import 'package:holy_quran/screens/donation_screen.dart';
import 'package:holy_quran/screens/prayer_screen.dart';
import 'package:holy_quran/screens/qibla_screen.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 5,),
            // qibla screen
            _buildIconButton(
              icon: Icons.explore,
              label: "Qibla Direction",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QiblaScreen()),
                );
              },
            ),


            // salah screen
            _buildIconButton(
              icon: Icons.access_time,
              label: "Prayer Times",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PrayerScreen()),
                );
              },
            ),

            // bookmark
            _buildIconButton(
              icon: Icons.bookmark,
              label: "Bookmark",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookmarksScreen()),
                );
              },
            ),


          ],
        ),
      ),
    );
  }
}

Widget _buildIconButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
