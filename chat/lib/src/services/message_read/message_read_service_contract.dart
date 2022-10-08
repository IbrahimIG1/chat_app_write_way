import 'package:chat/src/models/message_read_model.dart';

import '../../models/user_model.dart';

abstract class IMessageReadService
{
  Future<bool>sent (MessageReadModel messageReadModel);
  Stream<MessageReadModel> userMessageModelReceivers (User user);
  void dispose();
}