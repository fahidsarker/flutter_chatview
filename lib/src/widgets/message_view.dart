import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/chat_view_inherited_widget.dart';
import 'package:chatview/src/widgets/compound_message_view.dart';
import 'package:chatview/src/widgets/download_state.dart';
import 'package:chatview/src/widgets/video_player_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:chatview/src/extensions/extensions.dart';
import '../utils/constants/constants.dart';
import 'image_message_view.dart';
import 'text_message_view.dart';
import 'reaction_widget.dart';
import 'voice_message_view.dart';

class MessageView extends StatefulWidget {
  const MessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    required this.onLongPress,
    required this.isLongPressEnable,
    this.chatBubbleMaxWidth,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.longPressAnimationDuration,
    this.onDoubleTap,
    this.highlightColor = Colors.grey,
    this.shouldHighlight = false,
    this.highlightScale = 1.2,
    this.messageConfig,
    this.onMaxDuration,
    this.controller,
  }) : super(key: key);

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Give callback once user long press on chat bubble.
  final DoubleCallBack onLongPress;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Allow users to give duration of animation when user long press on chat bubble.
  final Duration? longPressAnimationDuration;

  /// Allow user to set some action when user double tap on chat bubble.
  final MessageCallBack? onDoubleTap;

  /// Allow users to pass colour of chat bubble when user taps on replied message.
  final Color highlightColor;

  /// Allow users to turn on/off highlighting chat bubble when user tap on replied message.
  final bool shouldHighlight;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  /// Allow user to giving customisation different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Allow user to turn on/off long press tap on chat bubble.
  final bool isLongPressEnable;

  final ChatController? controller;

  final Function(int)? onMaxDuration;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  MessageConfiguration? get messageConfig => widget.messageConfig;

  bool get isLongPressEnable => widget.isLongPressEnable;

  @override
  void initState() {
    super.initState();
    if (isLongPressEnable) {
      _animationController = AnimationController(
        vsync: this,
        duration: widget.longPressAnimationDuration ??
            const Duration(milliseconds: 250),
        upperBound: 0.1,
        lowerBound: 0.0,
      );
      if (widget.message.status != MessageStatus.read &&
          !widget.isMessageBySender) {
        widget.inComingChatBubbleConfig?.onMessageRead?.call(widget.message);
      }
      _animationController?.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController?.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.message.messageType.toString());

    return GestureDetector(
      onLongPressStart: isLongPressEnable ? _onLongPressStart : null,
      onDoubleTap: () {
        if (widget.onDoubleTap != null) widget.onDoubleTap!(widget.message);
      },
      child: (() {
        if (isLongPressEnable) {
          return AnimatedBuilder(
            builder: (_, __) {
              return Transform.scale(
                scale: 1 - _animationController!.value,
                child: _messageView,
              );
            },
            animation: _animationController!,
          );
        } else {
          return _messageView;
        }
      }()),
    );
  }

  Widget get _messageView {
    final emojiMessageConfiguration = messageConfig?.emojiMessageConfig;
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.message.reactions.reactions.isNotEmpty ? 6 : 0,
      ),
      child: FutureBuilder(
          future: messageConfig?.preprocessMessage?.call(widget.message) ??
              Future.value(widget.message),
          builder: (_, snap) {
            final data = snap.data;

            if (data == null) {
              return CircularProgressIndicator();
            }

            final message = data.message;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                (() {
                      if (data.unsent) {
                        return TextMessageView(
                          inComingChatBubbleConfig:
                              widget.inComingChatBubbleConfig,
                          outgoingChatBubbleConfig:
                              widget.outgoingChatBubbleConfig,
                          isMessageBySender: widget.isMessageBySender,
                          message: data.copyWith(
                            message: 'Message Unsent',
                            // messageType: MessageType.text,
                          ),
                          chatBubbleMaxWidth: widget.chatBubbleMaxWidth,
                          messageReactionConfig:
                              messageConfig?.messageReactionConfig,
                          highlightColor: widget.highlightColor,
                          highlightMessage: widget.shouldHighlight,
                          isUnsent: true,
                        );
                      } else if (message.isAllEmoji && message.length < 5) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: emojiMessageConfiguration?.padding ??
                                  EdgeInsets.fromLTRB(
                                    leftPadding2,
                                    4,
                                    leftPadding2,
                                    data.reactions.reactions.isNotEmpty
                                        ? 14
                                        : 0,
                                  ),
                              child: Transform.scale(
                                scale: widget.shouldHighlight
                                    ? widget.highlightScale
                                    : 1.0,
                                child: Text(
                                  message,
                                  style: emojiMessageConfiguration?.textStyle ??
                                      const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            if (data.reactions.reactions.isNotEmpty)
                              ReactionWidget(
                                reaction: data.reactions,
                                messageReactionConfig:
                                    messageConfig?.messageReactionConfig,
                                isMessageBySender: widget.isMessageBySender,
                              ),
                          ],
                        );
                      } else if (data.assetDownloadRequired) {
                        return DownloadRequired(
                          height: ImageMessageView.thumbnailHeight,
                          width: ImageMessageView.thumbnailWidth,
                          message: data,
                          controller: widget.controller,
                          messageConfiguration: messageConfig,
                          isMessageBySender: widget.isMessageBySender,
                        );
                      } else if (data.messageType.isImage) {
                        return ImageMessageView(
                          message: data,
                          censoredNotifier:
                              widget.controller?.enabledCensoredModeNotifier ??
                                  ValueNotifier<bool>(false),
                          isMessageBySender: widget.isMessageBySender,
                          imageMessageConfig: messageConfig?.imageMessageConfig,
                          messageReactionConfig:
                              messageConfig?.messageReactionConfig,
                          highlightImage: widget.shouldHighlight,
                          highlightScale: widget.highlightScale,
                          messageConfiguration: messageConfig,
                        );
                      } else if (data.messageType.isText) {
                        return TextMessageView(
                          inComingChatBubbleConfig:
                              widget.inComingChatBubbleConfig,
                          outgoingChatBubbleConfig:
                              widget.outgoingChatBubbleConfig,
                          isMessageBySender: widget.isMessageBySender,
                          message: data,
                          chatBubbleMaxWidth: widget.chatBubbleMaxWidth,
                          messageReactionConfig:
                              messageConfig?.messageReactionConfig,
                          highlightColor: widget.highlightColor,
                          highlightMessage: widget.shouldHighlight,
                        );
                      } else if (data.messageType.isVoice) {
                        return VoiceMessageView(
                          screenWidth: MediaQuery.of(context).size.width,
                          message: data,
                          config: messageConfig?.voiceMessageConfig,
                          onMaxDuration: widget.onMaxDuration,
                          isMessageBySender: widget.isMessageBySender,
                          messageReactionConfig:
                              messageConfig?.messageReactionConfig,
                          inComingChatBubbleConfig:
                              widget.inComingChatBubbleConfig,
                          outgoingChatBubbleConfig:
                              widget.outgoingChatBubbleConfig,
                        );
                      } else if (data.messageType.isVideo) {
                        return VideoPlayerThumbnail(
                          message: data,
                          isMessageBySender: widget.isMessageBySender,
                          imageMessageConfig:
                              widget.messageConfig?.imageMessageConfig,
                          messageReactionConfig:
                              widget.messageConfig?.messageReactionConfig,
                        );
                      } else if (data.messageType.isCompound) {
                        return CompoundMessageView(
                          message: data.copyWith(
                            // assets: [data.assets[0], data.assets[1]],
                          ),
                          isMessageBySender: widget.isMessageBySender,
                          imageMessageConfig:
                              widget.messageConfig?.imageMessageConfig,
                          messageReactionConfig:
                              widget.messageConfig?.messageReactionConfig,
                          inComingChatBubbleConfig: widget.inComingChatBubbleConfig,
                          outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
                        );
                      } else if (data.messageType.isCustom &&
                          messageConfig?.customMessageBuilder != null) {
                        return messageConfig?.customMessageBuilder!(data);
                      }
                    }()) ??
                    const SizedBox(),
                if (widget.isMessageBySender &&
                    widget.controller?.initialMessageList.last.id == data.id &&
                    data.status == MessageStatus.read)
                  if (ChatViewInheritedWidget.of(context)
                          ?.featureActiveConfig
                          .lastSeenAgoBuilderVisibility ??
                      true)
                    widget.outgoingChatBubbleConfig?.receiptsWidgetConfig
                            ?.lastSeenAgoBuilder
                            ?.call(data,
                                applicationDateFormatter(data.createdAt)) ??
                        lastSeenAgoBuilder(
                            data, applicationDateFormatter(data.createdAt))
                  else
                    const SizedBox()
                else
                  const SizedBox()
              ],
            );
          }),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) async {
    await _animationController?.forward();
    widget.onLongPress(
      details.globalPosition.dy - 120 - 64,
      details.globalPosition.dx,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
