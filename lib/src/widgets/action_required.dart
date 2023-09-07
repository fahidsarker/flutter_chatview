import 'dart:io';
import 'dart:math';

import 'package:chatview/src/widgets/compound_message_view.dart';
import 'package:chatview/src/widgets/video_player_thumbnail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../chatview.dart';
import 'censored.dart';

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
            onPressed: () =>
                controller!.downloadAndDecryptMessageAsset(message),
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
      return Opacity(opacity: 0.1, child: _icon);
    }

    if (message.isUploading) {
      return Opacity(
        opacity: 0.3,
        child: childBuilder(),
      );
    }

    return childBuilder();
  }

  Widget get _icon {
    if (message.messageType.isImage) {
      final asset = message.assets[0];
      AssetImage? image = asset.assetDownloadRequired ? messageConfiguration?.getAssetIcon?.call('photo') : null;
      if (image == null && asset.assetDownloadRequired) {
        return Censored(
          height: ImageMessageView.thumbnailHeight,
          width: ImageMessageView.thumbnailWidth,
          messageConfiguration: messageConfiguration,
          type: asset.type,
        );
      }
      return Container(
        height: ImageMessageView.thumbnailHeight,
        width: ImageMessageView.thumbnailWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: (image as ImageProvider?) ?? FileImage(File(asset.url)),
            fit: BoxFit.fitWidth,
          ),
        ),
      );
    }

    if (message.messageType.isVideo) {
      final asset = message.assets[0];
      AssetImage? image = asset.assetDownloadRequired
          ? messageConfiguration?.getAssetIcon?.call('video')
          : null;
      if (image == null && asset.assetDownloadRequired) {
        return Censored(
          height: ImageMessageView.thumbnailHeight,
          width: ImageMessageView.thumbnailWidth,
          messageConfiguration: messageConfiguration,
          type: asset.type,
        );
      }
      return VideoPlayerThumbnail(
        message: message,
        isMessageBySender: isMessageBySender,
        censoredNotifier: ValueNotifier(false),
        thumbnailImage: image == null
            ? null
            : DecorationImage(
                image: image,
                fit: BoxFit.fitWidth,
              ),
      );
    }

    if (message.messageType.isCompound) {
      return CompoundMessageView(
        message: message,
        isMessageBySender: isMessageBySender,
        lockNotifier: ValueNotifier(false),
        messageConfiguration: messageConfiguration,
      );
    }

    return Icon(Icons.question_mark_sharp);
  }
}
