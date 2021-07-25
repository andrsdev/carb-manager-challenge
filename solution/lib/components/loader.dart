import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  Loader({
    Key? key,
    this.size = 24,
    this.strokeWidth = 2,
    this.color = Colors.white,
  }) : super(key: key);

  final double size;
  final double strokeWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: this.size,
        width: this.size,
        child: CircularProgressIndicator(
          strokeWidth: this.strokeWidth,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(this.color),
          value: null,
        ),
      ),
    );
  }
}
