import 'package:flutter/material.dart';

class Censored extends StatelessWidget {
  final double? height;
  final double? width;

  const Censored({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.lock,
          color: Colors.grey[500],
          size: 30,
        ),
      ),
    );
  }
}
