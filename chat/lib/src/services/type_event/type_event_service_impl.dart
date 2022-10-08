import 'dart:async';
import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/models/type_event_model.dart';
import 'package:chat/src/services/type_event/type_event_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class TypingNotification implements ITypingNotification {
  final RethinkDb _r;
  final Connection _connection;
  final _controller = StreamController<TypingEventModel>.broadcast();
  StreamSubscription? _changeFeed;

  TypingNotification(this._r, this._connection);
  @override
  void dispose() {
    _connection.close();
    // _changeFeed!.cancel();
  }

  @override
  Future<bool> sent({required TypingEventModel event, required User to}) async {
    // final receiver = await _userService!.fetch(event.to);
    if (!to.active) return false;
    Map record = await _r
        .table('typing_events')
        .insert(event.toJson(), {'conflict': 'update'}).run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<TypingEventModel> subscribe(User user, List<String> userIds) {
    // _startReceivingTypingEvents(user, userIds);
    return _controller.stream;
  }

  _startReceivingTypingEvents(User user, List<String> userIds) {
    _changeFeed = _r
        .table('typing_events')
        .filter(( event) {
          return event('to') // return "to => user will receive message"
              .eq(user.gId) // sure "to Id" is = user.gId
              .and(_r.expr(userIds).contains(event( 
                  'from'))); // and sure usersIds List have The userId who i talk with
        })
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((element) {
                if (element['new_val'] == null) return;
                final typingResult = typeFromFeed(element);
                _controller.sink.add(typingResult);
                _removeEvent(typingResult);
              })
              .catchError((error) => print('$error Error In subscribe Listen'))
              .onError((error, stackTrace) => print(error));
        });
  }

  TypingEventModel typeFromFeed(feedData) {
    var data = feedData['new_val'];
    return TypingEventModel.fromJson(data);
  }
  _removeEvent(TypingEventModel event)
  {
    _r.table('typing_events').get(event.gId).delete({'return_changes' : false}).run(_connection);
  }
}
