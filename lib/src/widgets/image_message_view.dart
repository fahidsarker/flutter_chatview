/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:convert';
import 'dart:io';

import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/models/models.dart';
import 'package:chatview/src/widgets/censored.dart';
import 'package:flutter/material.dart';

import 'reaction_widget.dart';
import 'share_icon.dart';

class ImageMessageView extends StatefulWidget {

  static const thumbnailHeight = 200.0;
  static const thumbnailWidth = 150.0;

  const ImageMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
    required this.censoredNotifier,
    this.messageConfiguration,
  }) : super(key: key);

  final ValueNotifier<bool> censoredNotifier;

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration for image message appearance.
  final ImageMessageConfiguration? imageMessageConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents flag of highlighting image when user taps on replied image.
  final bool highlightImage;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  final MessageConfiguration? messageConfiguration;


  @override
  State<ImageMessageView> createState() => _ImageMessageViewState();
}

class _ImageMessageViewState extends State<ImageMessageView> {
  String get imageUrl => widget.message.assetUrl;

  Widget get iconButton => IconButton(onPressed: (){}, icon: Icon(Icons.emoji_emotions_outlined));

  @override
  Widget build(BuildContext context) {
    final height= widget.imageMessageConfig?.height ?? ImageMessageView.thumbnailHeight;
    final width= widget.imageMessageConfig?.width ?? ImageMessageView.thumbnailWidth;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          widget.isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // if (widget.isMessageBySender) iconButton,
        Stack(
          children: [
            GestureDetector(
              onTap: () => widget.imageMessageConfig?.onTap != null
                  ? widget.imageMessageConfig?.onTap!(context, widget.message)
                  : null,
              child: Transform.scale(
                scale: widget.highlightImage ? widget.highlightScale : 1.0,
                alignment: widget.isMessageBySender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: widget.imageMessageConfig?.padding ?? EdgeInsets.zero,
                  margin: widget.imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: widget.isMessageBySender ? 6 : 0,
                        left: widget.isMessageBySender ? 0 : 6,
                        bottom: widget.message.reactions.reactions.isNotEmpty ? 15 : 0,
                      ),
                  height: height,
                  width: width,
                  child: ClipRRect(
                    borderRadius: widget.imageMessageConfig?.borderRadius ?? BorderRadius.circular(14),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: widget.censoredNotifier,
                      child: (() {
                        if (imageUrl.isUrl) {
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.fitHeight,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                      null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          );
                        } else if (imageUrl.fromMemory) {
                          return Image.memory(
                            base64Decode(imageUrl
                                .substring(imageUrl.indexOf('base64') + 7)),
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Image.file(
                            File(imageUrl),
                            fit: BoxFit.cover,
                          );
                        }
                      }()),
                      builder: (_, value, child) {
                        return value ?  Censored(type: widget.message.messageType, height: height, width: width, messageConfiguration: widget.messageConfiguration,) : child!;
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (widget.message.reactions.reactions.isNotEmpty)
              ReactionWidget(
                isMessageBySender: widget.isMessageBySender,
                reaction: widget.message.reactions,
                messageReactionConfig: widget.messageReactionConfig,
              ),
          ],
        ),
        // if (!widget.isMessageBySender) iconButton,
      ],
    );
  }
}
