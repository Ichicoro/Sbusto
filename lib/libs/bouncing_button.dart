import 'package:flutter/material.dart';

class Bouncing extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scale;
  final Duration duration;

  const Bouncing({
    required this.child,
    required this.onPressed,
    this.scale = 0.1,
    this.duration = const Duration(milliseconds: 100),
    super.key,
  });

  @override
  State<Bouncing> createState() => _BouncingState();
}

class _BouncingState extends State<Bouncing>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: widget.scale,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (details) {
        _controller.forward();
      },
      onTapUp: (details) {
        _controller.reverse();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      onTap: () {
        widget.onPressed();
      },
      child: Transform.scale(scale: _scale, child: widget.child),
    );
  }
}
