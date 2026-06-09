import 'package:flutter/material.dart';

class MentorSearchBar
    extends StatelessWidget {

  final TextEditingController controller;
  final Function(String) onChanged;

  const MentorSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding:
          const EdgeInsets.all(10),

      child: TextField(
        controller: controller,

        decoration:
            const InputDecoration(
          hintText:
              "Search Student",

          prefixIcon:
              Icon(Icons.search),

          border:
              OutlineInputBorder(),
        ),

        onChanged: onChanged,
      ),
    );
  }
}