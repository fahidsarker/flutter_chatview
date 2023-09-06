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

import '../values/enumaration.dart';

class ReplyMessage {
  /// Provides reply message.
  final String message;

  /// Provides user id of who replied message.
  final String replyBy;

  /// Provides user id of whom to reply.
  final String replyTo;

  MessageType get messageType => assets.isEmpty
      ? MessageType.text
      : assets.length > 1
          ? MessageType.compound
          : assets.first.type;

  /// Provides max duration for recorded voice message.
  final Duration? voiceMessageDuration;

  /// Id of message, it replies to.
  final String messageId;

  final bool isValid;

  // String get assetUrl => asset?.url ?? '';

  final List<AssetModel> assets;

  const ReplyMessage({
    this.messageId = '',
    this.message = '',
    this.replyTo = '',
    this.replyBy = '',
    // this.messageType = MessageType.text,
    this.voiceMessageDuration,
    // this.assetUrl = '',
    this.isValid = true,
    List<AssetModel>? assets,
  }) : assets = assets ?? const [];

  factory ReplyMessage.fromJson(Map<String, dynamic> json) => ReplyMessage(
        message: json['message'],
        replyBy: json['replyBy'],
        replyTo: json['replyTo'],
        // messageType: MessageType.values.firstWhere((element) => element.name == json["message_type"]),
        messageId: json["id"],
        voiceMessageDuration: json["voiceMessageDuration"] == null
            ? null
            : Duration(milliseconds: json["voiceMessageDuration"]),
        isValid: json["isValid"] ?? true,
        // assetUrl: json["assetUrl"] ?? '',
        assets: json["assets"] == null
            ? []
            : List<AssetModel>.from(
                json["assets"].map((x) => AssetModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'replyBy': replyBy,
        'replyTo': replyTo,
        // 'message_type': messageType.name,
        'id': messageId,
        'voiceMessageDuration': voiceMessageDuration?.inMilliseconds,
        'isValid': isValid,
        // 'assetUrl': assetUrl,
        'assets': assets.map((e) => e.toJson()),
      };

  ReplyMessage copyWith({bool? isValid, String? message, List<AssetModel>? assets}) {
    return ReplyMessage(
      isValid: isValid ?? this.isValid,
      message: message ?? this.message,
      replyBy: replyBy,
      replyTo: replyTo,
      // messageType: messageType,
      voiceMessageDuration: voiceMessageDuration,
      messageId: messageId,
      // assetUrl: assetUrl ?? this.assetUrl,
      assets: assets ?? this.assets
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplyMessage &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          replyBy == other.replyBy &&
          replyTo == other.replyTo &&
          // messageType == other.messageType &&
          voiceMessageDuration == other.voiceMessageDuration &&
          messageId == other.messageId &&
          isValid == other.isValid &&
          // assetUrl == other.assetUrl;
          // asset == other.asset;
          assets == other.assets;

  @override
  int get hashCode =>
      message.hashCode ^
      replyBy.hashCode ^
      replyTo.hashCode ^
      // messageType.hashCode ^
      voiceMessageDuration.hashCode ^
      messageId.hashCode ^
      isValid.hashCode ;
}
