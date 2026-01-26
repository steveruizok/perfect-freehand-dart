import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        'perfect_freehand',
        style: TextTheme.of(context).titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
