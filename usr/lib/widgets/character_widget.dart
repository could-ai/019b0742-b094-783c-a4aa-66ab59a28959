import 'package:flutter/material.dart';

class CharacterWidget extends StatelessWidget {
  final bool isSpeaking;

  const CharacterWidget({super.key, this.isSpeaking = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body
          Positioned(
            bottom: 0,
            child: Container(
              width: 100,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          // Head
          Positioned(
            top: 20,
            child: Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCCAA), // Skin tone
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12, width: 2),
              ),
            ),
          ),
          // Hair
          Positioned(
            top: 15,
            child: Container(
              width: 95,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.brown.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          // Eyes
          Positioned(
            top: 55,
            left: 55,
            child: _buildEye(),
          ),
          Positioned(
            top: 55,
            right: 55,
            child: _buildEye(),
          ),
          // Mouth
          Positioned(
            top: 85,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSpeaking ? 20 : 15,
              height: isSpeaking ? 15 : 5,
              decoration: BoxDecoration(
                color: isSpeaking ? Colors.red.shade300 : Colors.red.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
    );
  }
}
