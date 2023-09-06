import 'dart:typed_data';

import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/censored.dart';
import 'package:chatview/src/widgets/reaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

class VideoPlayerThumbnail extends StatelessWidget {
  final Message message;
  final ImageMessageConfiguration? imageMessageConfig;
  final bool isMessageBySender;
  final MessageReactionConfiguration? messageReactionConfig;
  final bool forReply;
  final DecorationImage? thumbnailImage;
  final ValueNotifier<bool> censoredNotifier;
  final MessageConfiguration? messageConfiguration;

  const VideoPlayerThumbnail({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.thumbnailImage,
    required this.censoredNotifier,
    this.messageConfiguration,
    this.messageReactionConfig,
    this.forReply = false,
  }) : super(key: key);

  Future<Uint8List?> _getThumbnailData() async {
    return await vt.VideoThumbnail.thumbnailData(
      video:
          forReply ? message.replyMessage.assets[0].url : message.assets[0].url,
      imageFormat: vt.ImageFormat.JPEG,
      quality: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = imageMessageConfig?.width ?? ImageMessageView.thumbnailWidth;
    final height =
        imageMessageConfig?.height ?? ImageMessageView.thumbnailHeight;
    final asset = forReply ? message.replyMessage.assets[0] : message.assets[0];

    return InkWell(
      onTap: () => imageMessageConfig?.onTap?.call(context, asset),
      child: thumbnailImage != null
          ? Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: thumbnailImage!),
            )
          : Stack(
              children: [
                Container(
                  margin: imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: isMessageBySender ? 6 : 0,
                        left: isMessageBySender ? 0 : 6,
                        bottom: message.reactions.reactions.isNotEmpty ? 15 : 0,
                      ),
                  child: FutureBuilder(
                    future: _getThumbnailData(),
                    builder: (_, snap) {
                      final data = snap.data;
                      if (data == null) {
                        return Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                  opacity: 0.5,
                                  child: Icon(
                                    Icons.movie_creation_outlined,
                                    size: 100,
                                  )),
                              CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ],
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ValueListenableBuilder(
                            valueListenable: censoredNotifier,
                            builder: (_, v, __) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  (() {
                                    if (v) {
                                      final lockedIconImage =
                                          messageConfiguration?.getAssetIcon
                                              ?.call('video');

                                      if (lockedIconImage == null) {
                                        return Censored(
                                          messageConfiguration:
                                              messageConfiguration,
                                          type: MessageType.video,
                                          width: width,
                                          height: height,
                                        );
                                      }

                                      return Container(
                                        width: width,
                                        height: height,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                                image: lockedIconImage,
                                                fit: BoxFit.fitWidth)),
                                      );
                                    }

                                    return Image.memory(
                                      data,
                                      fit: BoxFit.cover,
                                      height: height,
                                      width: width,
                                    );
                                  }()),
                                  if (!v)...[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(800),
                                      ),
                                      width: 48,
                                      height: 48,
                                    ),

                                    const Icon(
                                      Icons.play_circle,
                                      size: 48,
                                      color: Colors.black,
                                    ),
                                  ]
                                ],
                              );
                            }),
                      );
                    },
                  ),
                ),
                if (!forReply && message.reactions.reactions.isNotEmpty)
                  ReactionWidget(
                    isMessageBySender: isMessageBySender,
                    reaction: message.reactions,
                    messageReactionConfig: messageReactionConfig,
                  ),
              ],
            ),
    );
  }
}
