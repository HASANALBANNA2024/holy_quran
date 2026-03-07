import 'package:flutter/material.dart';
import 'package:holy_quran/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("নোটিফিকেশন ইনবক্স"),
        actions: [IconButton(icon: Icon(Icons.delete_sweep), onPressed: () => provider.clearAll())],
      ),
      body: provider.list.isEmpty
          ? Center(child: Text("কোনো নোটিফিকেশন নেই"))
          : ListView.builder(
        itemCount: provider.list.length,
        itemBuilder: (context, index) {
          final item = provider.list[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.auto_awesome, color: Colors.white)),
            title: Text(item.category, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.text, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.bookmark_border), onPressed: () {
                  // এখানে তোমার বুকমার্ক প্রোভাইডার কল করবে
                }),
                IconButton(icon: Icon(Icons.close, size: 18), onPressed: () => provider.removeOne(item.id)),
              ],
            ),
            onTap: () {
              // ওভারলে কার্ড দেখানোর লজিক
            },
          );
        },
      ),
    );
  }
}