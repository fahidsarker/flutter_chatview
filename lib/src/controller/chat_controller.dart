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
import 'dart:async';

import 'package:chatview/src/utils/message_notifier.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class ChatController {
  /// Represents initial message list in chat which can be add by user.
  List<MessageNotifier> initialMessageList;

  ScrollController scrollController;

  final ChatUser currentUser;

  /// Allow user to show typing indicator defaults to false.
  final ValueNotifier<ChatUser?> _showTypingIndicatorFor = ValueNotifier(null);

  // final ValueNotifier<bool> _showTypingIndicator = ValueNotifier(false);

  /// TypingIndicator as [ValueNotifier] for [GroupedChatList] widget's typingIndicator [ValueListenableBuilder].
  ///  Use this for listening typing indicators
  ///   ```dart
  ///    chatcontroller.typingIndicatorNotifier.addListener((){});
  ///  ```
  /// For more functionalities see [ValueNotifier].
  ValueNotifier<ChatUser?> get typingIndicatorNotifierFor =>
      _showTypingIndicatorFor;

  /// Getter for typingIndicator value instead of accessing [_showTypingIndicator.value]
  /// for better accessibility.
  // bool get showTypingIndicator => _showTypingIndicator.value;
  ChatUser? get showingTypingIndicatorFor => _showTypingIndicatorFor.value;

  /// Setter for changing values of typingIndicator
  /// ```dart
  ///  chatContoller.setTypingIndicator = true; // for showing indicator
  ///  chatContoller.setTypingIndicator = false; // for hiding indicator
  ///  ````
  // set setTypingIndicator(bool value) => _showTypingIndicator.value = value;
  set setTypingIndicator(String? userID) =>
      _showTypingIndicatorFor.value = userID == null
          ? null
          : chatUsers.firstWhere((element) => element.id == userID);

  /// Represents list of chat users
  List<ChatUser> chatUsers;

  ChatController({
    required this.initialMessageList,
    required this.scrollController,
    required this.chatUsers,
    required this.onReactionSet,
    required this.onRemoveReact,
    required this.currentUser,
  });

  final Function(
    String emoji,
    String messageId,
    String userId,
  ) onReactionSet;

  final Function(
    String emoji,
    String messageId,
    String userId,
  ) onRemoveReact;

  /// Represents message stream of chat
  StreamController<List<MessageNotifier>> messageStreamController = StreamController();

  /// Used to dispose stream.
  void dispose() => messageStreamController.close();

  /// Used to add message in message list.
  void addMessage(Message message) {
    initialMessageList.add(MessageNotifier(message));
    messageStreamController.sink.add(initialMessageList);
  }


  // if message does not exist in list then add message in list at the top
  void updateMessageList(List<Message> messages) {
    final nList = [...initialMessageList];
    bool needToSink = false;
    for (final message in messages) {
      final mIndex = nList.indexWhere((element) => element.value.id == message.id);
      if (mIndex == -1) {
        needToSink = true;
        nList.add(MessageNotifier(message));
      } else if (!needToSink){
        nList[mIndex].updateMessage(message);
      }
    }

    if (needToSink) {
      nList.sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      initialMessageList = nList;
      messageStreamController.sink.add(initialMessageList);
    }

  }

  /// Function for setting reaction on specific chat bubble
  void setReaction({
    required String emoji,
    required String messageId,
    required String userId,
  }) {
    onReactionSet(emoji, messageId, userId);
  }

  /// Function to scroll to last messages in chat view
  void scrollToLastMessage() => Timer(
        const Duration(milliseconds: 300),
        () => scrollController.animateTo(
          scrollController.position.minScrollExtent,
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 300),
        ),
      );

  // /// Function for loading data while pagination.
  // void loadMoreData(List<Message> messageList) {
  //   /// Here, we have passed 0 index as we need to add data before first data
  //   initialMessageList.insertAll(0, messageList);
  //   messageStreamController.sink.add(initialMessageList);
  // }

  /// Function for getting ChatUser object from user id
  ChatUser getUserFromId(String userId) => chatUsers.firstWhere(
        (element) => element.id == userId,
      );

  final ValueNotifier<bool> _enabledCensoredMode = ValueNotifier(true);

  ValueNotifier<bool> get enabledCensoredModeNotifier => _enabledCensoredMode;

  bool get enabledCensoredMode => _enabledCensoredMode.value;

  set enabledCensoredMode(bool value) => _enabledCensoredMode.value = value;

}
