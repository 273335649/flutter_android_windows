import 'package:flutter/material.dart';

class WebInputPositioned extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const WebInputPositioned({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 1,
      left: 1,
      child: Transform.translate(
        offset: const Offset(1, 1),
        child: SizedBox(
          width: 0.1,
          height: 0.1,
          child: TextField(
            style: TextStyle(color: Colors.yellow),
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            decoration: const InputDecoration(
              hintText: "Web Input",
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow),
              ),
              hintStyle: TextStyle(color: Colors.yellow),
              labelStyle: TextStyle(color: Colors.yellow),
            ),
          ),
        ),
      ),
    );
  }
}