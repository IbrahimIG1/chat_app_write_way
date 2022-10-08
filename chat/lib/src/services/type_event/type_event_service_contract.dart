import 'package:chat/src/models/type_event_model.dart';
import 'package:chat/src/models/user_model.dart';

abstract class ITypingEventService
{
  Future<bool> sent (TypeEventModel typeEventModel);
  Stream<TypeEventModel> subscribe(User user , List<String>usreIds);
  void dispose();
}