/// test is used to test the equality of the message
///

import 'package:chatview/chatview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('message equality test', () {
    final message1 = Message(
      id: '1',
      message: 'message',
      createdAt: DateTime(2021, 1, 1),
      sendBy: '1',
      replyMessage: ReplyMessage(),
      reactions: Reactions('1', []),
      messageType: MessageType.text,
      status: MessageStatus.read,
    );
    final message2 = Message(
      id: '1',
      message: 'message',
      createdAt: DateTime(2021, 1, 1),
      sendBy: '1',
      replyMessage: ReplyMessage(),
      reactions: Reactions('1', []),
      messageType: MessageType.text,
      status: MessageStatus.read,
    );
    print(message1.differentFrom(message2));
    expect(message1, message2);
  });
}