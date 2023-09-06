import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../chatview.dart';

class ActionRequired extends StatelessWidget {
  final double height;
  final double width;
  final Message message;
  final ChatController? controller;
  final MessageConfiguration? messageConfiguration;
  final bool isMessageBySender;
  final Widget Function() childBuilder;

  const ActionRequired({
    Key? key,
    required this.height,
    required this.width,
    required this.message,
    required this.controller,
    required this.messageConfiguration,
    required this.isMessageBySender,
    required this.childBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('------------------ActionRequired------------------');
    // print(message.isDownloading);
    // print(message.isUploading);
    // print(message.assetDownloadRequired);

    if (message.isDownloading ||
        message.isUploading ||
        message.assetDownloadRequired) {
      return Stack(
        alignment: Alignment.center,
        children: [
          _displayableChild,
          IconButton(
            onPressed: () => controller!.downloadAndDecryptMessageAsset(message),
            icon: Icon(
              (message.isUploading) ? Icons.upload : Icons.download,
              color: messageConfiguration?.toDownloadIcon ?? Colors.black,
            ),
          ),
          if (message.isDownloading || message.isUploading)
            Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(
                  color: messageConfiguration?.toDownloadIcon ?? Colors.blue,
                ),
              ),
            ),
        ],
      );
    }

    return _displayableChild;
  }

  Widget get _displayableChild {
    if (message.assetDownloadRequired || message.isDownloading) {
      return Opacity(
        opacity: 0.1,
        child: message.assets.length > 1
            ? _compoundAssetWidget
            : Icon(
                _icon,
                size: min(height, width) * 0.8,
                color: messageConfiguration?.toDownloadIcon ?? Colors.black,
              ),
      );
    }

    if (message.isUploading) {
      return Opacity(
        opacity: 0.3,
        child: childBuilder(),
      );
    }

    return childBuilder();
  }

  IconData get _icon {
    if (message.assets.isEmpty) {
      return Icons.question_mark_sharp;
    }

    return message.assets[0].type.icon;
  }

  Widget get _compoundAssetWidget {
    return Text('Compound!');
  }
}
