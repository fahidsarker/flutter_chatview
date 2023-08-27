import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

class DownloadRequired extends StatefulWidget {
  final double height;
  final double width;
  final Message message;
  final ChatController? controller;
  final MessageConfiguration? messageConfiguration;
  final bool isMessageBySender;

  const DownloadRequired({
    super.key,
    required this.height,
    required this.width,
    required this.message,
    required this.controller,
    required this.messageConfiguration,
    required this.isMessageBySender,
  });

  @override
  State<DownloadRequired> createState() => _DownloadRequiredState();
}

class _DownloadRequiredState extends State<DownloadRequired> {
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height,
        width: widget.width,
        margin: widget.messageConfiguration?.imageMessageConfig?.margin ??
            EdgeInsets.only(
              top: 6,
              right: widget.isMessageBySender ? 6 : 0,
              left: widget.isMessageBySender ? 0 : 6,
              bottom: widget.message.reactions.reactions.isNotEmpty ? 15 : 0,
            ),
        decoration: BoxDecoration(
          color: widget.messageConfiguration?.toDownloadBack ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.1,
              child: Icon(
                widget.message.messageType.icon,
                size: min(widget.height, widget.width) * 0.8,
                color: widget.messageConfiguration?.toDownloadIcon ?? Colors.black,
              ),
            ),
            isDownloading
                ? CircularProgressIndicator(color: widget.messageConfiguration?.toDownloadIcon ?? Colors.blue,)
                : IconButton(
                    onPressed: () {
                      if (widget.controller != null) {
                        setState(() {
                          isDownloading = true;
                        });
                        widget.controller!.downloadAndDecryptMessageAsset(widget.message);
                      }
                    },
                    icon: Icon(
                      Icons.download,
                      color: widget.messageConfiguration?.toDownloadIcon ?? Colors.black,
                      size: (min(widget.height, widget.width) * 0.2),
                    ),
                  ),
          ],
        ));
  }
}
