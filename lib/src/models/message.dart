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
import 'package:chatview/chatview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class Message {
  /// Provides id
  final String id;

  /// Provides actual message it will be text or image/audio file path.
  final String message;

  /// Provides message created date time.
  final DateTime createdAt;

  /// Provides id of sender of message.
  final String sendBy;

  /// Provides reply message if user triggers any reply on any message.
  final ReplyMessage replyMessage;

  /// Represents reaction on message.
  final Reactions reactions;

  /// Provides message type.
  final MessageType messageType;

  /// Status of the message.
  final MessageStatus status;

  /// Provides max duration for recorded voice message.
  Duration? voiceMessageDuration;

  final String assetUrl;

  final bool unsent;

  final DateTime? readAt;

  final GlobalKey key;

  Message({
    required this.id,
    required this.message,
    required this.createdAt,
    this.assetUrl = '',
    required this.sendBy,
    this.replyMessage = const ReplyMessage(),
    Reactions? reactions,
    this.messageType = MessageType.text,
    this.voiceMessageDuration,
    required this.status,
    this.unsent = false,
    this.readAt,
  })  : key = GlobalKey(),
        reactions = reactions ?? Reactions(id, []),
        assert(
          (messageType.isVoice
              ? ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.android))
              : true),
          "Voice messages are only supported with android and ios platform",
        );

  String get uniqueSignature {
    return '$id${status.name}${reactions.reactions.map((e) => '${e.userID}${e.reaction}')}';
  }

  Message copyWith({
    String? message,
    String? assetUrl,
    ReplyMessage? replyMessage,
    MessageStatus? status,
  }) {
    return Message(
      id: id,
      message: message ?? this.message,
      createdAt: createdAt,
      sendBy: sendBy,
      replyMessage: replyMessage ?? this.replyMessage,
      reactions: reactions,
      messageType: messageType,
      voiceMessageDuration: voiceMessageDuration,
      status: status ?? this.status,
      assetUrl: assetUrl ?? this.assetUrl,
    );
  }

  /// returns values which are different from other message
  List<dynamic> differentFrom(Message other) {
    final list = <dynamic>[];
    if (message != other.message) {
      list.add(message);
    }
    if (assetUrl != other.assetUrl) {
      list.add(assetUrl);
    }
    if (replyMessage != other.replyMessage) {
      list.add(replyMessage);
    }
    if (status != other.status) {
      list.add(status);
    }

    if (reactions != other.reactions) {
      list.add(reactions);
    }

    if (messageType != other.messageType) {
      list.add(messageType);
    }

    if (voiceMessageDuration != other.voiceMessageDuration) {
      list.add(voiceMessageDuration);
    }

    if (createdAt != other.createdAt) {
      list.add(createdAt);
    }

    if (sendBy != other.sendBy) {
      list.add(sendBy);
    }

    if (id != other.id) {
      list.add(id);
    }

    if (unsent != other.unsent) {
      list.add(unsent);
    }

    if (readAt != other.readAt) {
      list.add(readAt);
    }

    if (key != other.key) {
      list.add(key);
    }

    return list;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message &&
          createdAt == other.createdAt &&
          sendBy == other.sendBy &&
          replyMessage == other.replyMessage &&
          reactions == other.reactions &&
          messageType == other.messageType &&
          status == other.status &&
          voiceMessageDuration == other.voiceMessageDuration &&
          assetUrl == other.assetUrl &&
          unsent == other.unsent &&
          readAt == other.readAt;

  @override
  int get hashCode =>
      id.hashCode ^
      message.hashCode ^
      createdAt.hashCode ^
      sendBy.hashCode ^
      replyMessage.hashCode ^
      reactions.hashCode ^
      messageType.hashCode ^
      status.hashCode ^
      voiceMessageDuration.hashCode ^
      assetUrl.hashCode ^
      unsent.hashCode ^
      readAt.hashCode;

  @override
  String toString() {
    return 'Message{id: $id, message: $message, createdAt: $createdAt, sendBy: $sendBy, replyMessage: $replyMessage, reactions: $reactions, messageType: $messageType, status: $status, voiceMessageDuration: $voiceMessageDuration, assetUrl: $assetUrl, unsent: $unsent, readAt: $readAt}';
  }
}
