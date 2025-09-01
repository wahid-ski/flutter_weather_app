import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AdditionalInformation extends StatelessWidget {
  final String lottiePath;
  final String label;
  final String value;

  const AdditionalInformation({
    super.key,
    required this.lottiePath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      
      children: [
        Lottie.asset(
          lottiePath,
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
