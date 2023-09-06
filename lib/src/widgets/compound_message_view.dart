import 'dart:io';

import 'package:chatview/src/widgets/reaction_widget.dart';
import 'package:chatview/src/widgets/video_player_thumbnail.dart';
import 'package:flutter/material.dart';

import '../../chatview.dart';

const _SPACING = 5.0;

class CompoundMessageView extends StatelessWidget {
  final Message message;
  final ImageMessageConfiguration? imageMessageConfig;
  final bool isMessageBySender;
  final MessageReactionConfiguration? messageReactionConfig;
  final ChatBubble? inComingChatBubbleConfig;
  final ChatBubble? outgoingChatBubbleConfig;

  const CompoundMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => imageMessageConfig?.onTap?.call(context, message.assets[1]),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(_SPACING),
            margin: imageMessageConfig?.margin ??
                EdgeInsets.only(
                  top: 6,
                  right: isMessageBySender ? 6 : 0,
                  left: isMessageBySender ? 0 : 6,
                  bottom: message.reactions.reactions.isNotEmpty ? 15 : 0,
                ),
            height: _totalHeight,
            width: _totalWidth,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _backGround.withOpacity(0.1)),
            child: _buildCompoundView(context),
          ),
          if (message.reactions.reactions.isNotEmpty)
            ReactionWidget(
              isMessageBySender: isMessageBySender,
              reaction: message.reactions,
              messageReactionConfig: messageReactionConfig,
            ),
        ],
      ),
    );
  }

  Widget _buildCompoundView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAsset(context, message.assets[0]),
            if (message.assetCount > 1) _buildAsset(context, message.assets[1]),
          ],
        ),
        if (message.assetCount > 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAsset(context, message.assets[2]),
              if (message.assetCount > 3)
                if (message.assetCount == 4)
                  _buildAsset(context, message.assets[3])
                else
                  Stack(
                    children: [
                      Opacity(
                          opacity: 0.5,
                          child: _buildAsset(context, message.assets[3])),
                      SizedBox(
                        height: _componentHeight,
                        width: _componentWidth,
                        child: Center(
                          child: Text(
                            '+${message.assetCount - 3}',
                            style: ((isMessageBySender
                                        ? outgoingChatBubbleConfig?.textStyle
                                        : inComingChatBubbleConfig?.textStyle) ?? const TextStyle()).copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ],
                  )
            ],
          ),
      ],
    );
  }

  Widget _buildAsset(BuildContext context, AssetModel asset) {
    if (asset.type == MessageType.image) {
      return _buildImage(context, asset);
    } else if (asset.type == MessageType.video) {
      return _buildVideoThumb(context, asset);
    } else {
      return Container();
    }
  }

  Widget _buildImage(BuildContext context, AssetModel asset) {
    return Container(
      height: _componentHeight,
      width: _componentWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: FileImage(File(asset.url)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVideoThumb(BuildContext context, AssetModel asset) {
    return VideoPlayerThumbnail(
      message: message.copyWith(
        assets: [asset],
        reactions: Reactions('', []),
      ),
      isMessageBySender: isMessageBySender,
      imageMessageConfig: ImageMessageConfiguration(
        height: _componentHeight,
        width: _componentWidth,
        margin: EdgeInsets.zero,
      ),
    );
  }

  Color get _backGround => isMessageBySender
      ? outgoingChatBubbleConfig?.color ?? Colors.blue
      : inComingChatBubbleConfig?.color ?? Colors.grey.shade200;

  double get _totalHeight =>
      (_componentHeight * (message.assetCount > 2 ? 2 : 1)) +
      _SPACING * (message.assetCount > 2 ? 3 : 2);

  double get _totalWidth => (_componentWidth * 2) + _SPACING * 3;

  double get _componentHeight => _componentWidth;

  double get _componentWidth =>
      (imageMessageConfig?.height ?? ImageMessageView.thumbnailHeight) / 2;
}
