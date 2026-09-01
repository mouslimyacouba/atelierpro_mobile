import 'package:flutter/material.dart';
import '../core/theme.dart';

class AtelierSpinner extends StatelessWidget {
  final String? label;
  const AtelierSpinner({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AtelierProColors.terracotta),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: const TextStyle(color: AtelierProColors.encre)),
          ],
        ],
      ),
    );
  }
}
