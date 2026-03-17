import 'package:flutter/material.dart';

class RemoteButton extends StatelessWidget {

  final String label;
  final VoidCallback onPressed;

  RemoteButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context){

    return Padding(

      padding: EdgeInsets.all(6),

      child: ElevatedButton(

        onPressed: onPressed,

        child: Text(label),

        style: ElevatedButton.styleFrom(
          minimumSize: Size(80,60),
        ),

      ),

    );

  }

}