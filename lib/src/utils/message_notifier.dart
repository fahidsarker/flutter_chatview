import 'package:chatview/chatview.dart';
import 'package:flutter/cupertino.dart';

class MessageNotifier extends ValueNotifier<Message>{
  MessageNotifier(Message value) : super(value);

  void updateMessage(Message message){
    if (message == (value)){
      return;
    }
    value = message;
    notifyListeners();
  }

  String get id => value.id;

}