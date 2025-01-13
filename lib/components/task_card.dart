import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String startTime;
  final String endTime;
  final int duration;
  final Color backgroundColor;
  final List<String> participants;

  TaskCard({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.backgroundColor,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '$startTime - $endTime',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$duration Min',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: participants.map((participant) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(participant),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
