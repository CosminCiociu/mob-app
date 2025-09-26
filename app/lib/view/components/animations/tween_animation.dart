import 'package:flutter/material.dart';

class TweenAnimation extends StatefulWidget {
  const TweenAnimation({super.key});

  @override
  State<TweenAnimation> createState() => _TweenAnimationState();
}

class _TweenAnimationState extends State<TweenAnimation> {
  double targetValue = 40;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0, end: targetValue),
      duration: const Duration(microseconds: 500),
      curve: Curves.easeIn,
      builder: (context, n, w) {
        return InkWell(
          onTap: () {
            setState(() {
              targetValue = targetValue == 40 ? 50 : 40;
            });
          },
          child: Icon(
            Icons.favorite,
            size: n.toDouble(),
            color: targetValue == 40 ? Colors.red : Colors.white,
          ),
        );
      },
    );
  }
}
