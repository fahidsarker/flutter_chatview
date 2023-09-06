import 'dart:math';

import 'package:flutter/material.dart';

import '../../chatview.dart';

class Censored extends StatelessWidget {
  final double? height;
  final double? width;
  final MessageType type;
  final MessageConfiguration? messageConfiguration;
  final Widget? child;

  const Censored(
      {Key? key,
      this.height,
      this.width,
      required this.messageConfiguration,
      required this.type, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: messageConfiguration?.toDownloadBack ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.1,
            child: child ?? Icon(
              type.icon,
              size: min(height ?? 0, width ?? 0) * 0.9,
            ),
          ),
          Icon(
            Icons.lock,
            color: messageConfiguration?.toDownloadIcon ?? Colors.black,
            size: min(height ?? 0, width ?? 0) * 0.4,
          ),
        ],
      ),
    );
  }
}
