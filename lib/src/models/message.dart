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
import 'package:chatview/src/models/asset.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
abstract class Message {
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


  /// Status of the message.
  final MessageStatus status;

  /// Provides max duration for recorded voice message.
  Duration? get voiceMessageDuration {
    final voiceMessageIndex = assets.indexWhere((element) => element.type == MessageType.voice);
    if (voiceMessageIndex != -1) {
      return assets[voiceMessageIndex].voiceMessageDuration;
    }
    return null;
  }

  set voiceMessageDuration(Duration? duration) {
    final voiceMessageIndex = assets.indexWhere((element) => element.type == MessageType.voice);
    if (voiceMessageIndex != -1) {
      assets[voiceMessageIndex].voiceMessageDuration = duration;
    }
  }

  final List<AssetModel> assets;

  final bool unsent;

  final DateTime? readAt;

  final GlobalKey key;

  // final bool assetDownloadRequired;


  MessageType get messageType => assets.isEmpty ? MessageType.text : assets.length == 1 ? assets.first.type : MessageType.compound;

  bool get assetDownloadRequired => assets.any((e) => e.assetDownloadRequired);

  bool get isDownloading => assets.any((e) => e.isDownloading);
  bool get isUploading => assets.any((e) => e.isUploading);

  Message({
    required this.id,
    required this.message,
    required this.createdAt,
    List<AssetModel>? assets,
    required this.sendBy,
    this.replyMessage = const ReplyMessage(),
    Reactions? reactions,
    // this.voiceMessageDuration,
    required this.status,
    this.unsent = false,
    this.readAt,
    // this.assetDownloadRequired = false,
  })  : key = GlobalKey(),
        assets = assets ?? [],
        reactions = reactions ?? Reactions(id, []);

  String get uniqueSignature {
    return '$id${status.name}${reactions.reactions.map((e) => '${e.userID}${e.reaction}')}${assets.map((e) => e.signature)}';
  }

  int get assetCount => assets.length;

  Message copyWith(
      {String? message,
      List<AssetModel>? assets,
      ReplyMessage? replyMessage,
        Reactions? reactions,
      MessageStatus? status});

  bool get _sameAssets {
    if (assets.length != assets.length) {
      return false;
    }
    for (var i = 0; i < assets.length; i++) {
      if (assets[i] != assets[i]) {
        return false;
      }
    }
    return true;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          message == other.message &&
          createdAt.isAtSameMomentAs(other.createdAt) &&
          sendBy == other.sendBy &&
          replyMessage == other.replyMessage &&
          reactions == other.reactions &&
          status == other.status &&
          const ListEquality().equals(assets, other.assets) &&
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
      status.hashCode ^
      assets.hashCode ^
      unsent.hashCode ^
      readAt.hashCode;

  bool get containsAsset => assets.isNotEmpty;


}
