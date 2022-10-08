import 'package:chat/src/models/type_event_model.dart';
import 'package:chat/src/models/user_model.dart';
import 'package:flutter/foundation.dart';

abstract class ITypingNotification
{
  Future<bool> sent ({required TypingEventModel event,required User to});
  Stream<TypingEventModel> subscribe(User user , List<String>usreIds);
  void dispose();
}