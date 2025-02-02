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
import 'package:chatview/src/models/models.dart';
import 'package:chatview/src/models/voice_message_configuration.dart';
import 'package:flutter/material.dart';

class MessageConfiguration {
  /// Provides configuration of image message appearance.
  final ImageMessageConfiguration? imageMessageConfig;

  /// Provides configuration of image message appearance.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Provides configuration of emoji messages appearance.
  final EmojiMessageConfiguration? emojiMessageConfig;

  /// Provides builder to create view for custom messages.
  final Widget Function(Message)? customMessageBuilder;

  // final Widget Function(Message, bool, MessageConfiguration?, bool, double)? encryptedMessageBuilder;

  final Future<Message> Function(Message)? preprocessMessage;

  /// Configurations for voice message bubble
  final VoiceMessageConfiguration? voiceMessageConfig;

  final Color? toDownloadBack;
  final Color? toDownloadIcon;

  final AssetImage Function(String)? getAssetIcon;

  const MessageConfiguration({
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.emojiMessageConfig,
    this.customMessageBuilder,
    this.voiceMessageConfig,
    this.preprocessMessage,
    this.toDownloadBack,
    this.toDownloadIcon,
    this.getAssetIcon,
  });

  MessageConfiguration copyWith({
ImageMessageConfiguration? imageMessageConfig,
    MessageReactionConfiguration? messageReactionConfig,
    EmojiMessageConfiguration? emojiMessageConfig,
    Widget Function(Message)? customMessageBuilder,
    // Widget Function(Message, bool, MessageConfiguration?, bool, double)? encryptedMessageBuilder,
    Future<Message> Function(Message)? preprocessMessage,
    VoiceMessageConfiguration? voiceMessageConfig,
    Color? toDownloadBack,
    Color? toDownloadIcon,
  }) {
    return MessageConfiguration(
      imageMessageConfig: imageMessageConfig ?? this.imageMessageConfig,
      messageReactionConfig: messageReactionConfig ?? this.messageReactionConfig,
      emojiMessageConfig: emojiMessageConfig ?? this.emojiMessageConfig,
      customMessageBuilder: customMessageBuilder ?? this.customMessageBuilder,
      // encryptedMessageBuilder: encryptedMessageBuilder ?? this.encryptedMessageBuilder,
      preprocessMessage: preprocessMessage ?? this.preprocessMessage,
      voiceMessageConfig: voiceMessageConfig ?? this.voiceMessageConfig,
      toDownloadBack: toDownloadBack ?? this.toDownloadBack,
      toDownloadIcon: toDownloadIcon ?? this.toDownloadIcon,
    );
  }

}
