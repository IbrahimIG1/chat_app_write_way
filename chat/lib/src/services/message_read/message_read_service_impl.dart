import 'dart:async';

import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/models/message_read_model.dart';
import 'package:chat/src/services/message_read/message_read_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class MessageReadService implements IMessageReadService {
  final RethinkDb r;
  final Connection _connection;
  final _controller = StreamController<MessageReadModel>.broadcast(); // الى بيضيف الداتا ف الداتابيز
  MessageReadService(this.r, this._connection);
  StreamSubscription? _changeFeed;  // الى بيسمع التغيرات علشان الكنترولر يضيف الداتا الجديدة
  @override
  void dispose() {
    _controller.close(); // close Stream
    _changeFeed!.cancel();
  }

  @override
  Future<bool> sent(MessageReadModel messageReadModel) async {
    //  inserted messages in messageReceipts table
    Map record = await r
        .table('messageReceipts')
        .insert(messageReadModel.toJson())
        .run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<MessageReadModel> userMessageModelReceivers(User user) {
    _changeFeed = r
        .table('messageReceipts')
        .filter({'receiver': user.gId})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((element) {
                if (element['new_val'] == null) return;
                final receiptResult = receiptFromFeed(element);
                _controller.sink.add(receiptResult);
              })
              .catchError((error) =>
                  print('$error Error In userMessageModelReceivers Listen'))
              .onError((error, stackTrace) => print(error));
        });
    return _controller.stream;
  }

  MessageReadModel receiptFromFeed(feedDate) {
    var data = feedDate['new_val'];
    return MessageReadModel.fromJson(data);
  }
}
