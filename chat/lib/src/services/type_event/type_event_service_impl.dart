import 'dart:async';
import 'package:chat/src/models/user_model.dart';
import 'package:chat/src/models/type_event_model.dart';
import 'package:chat/src/services/type_event/type_event_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class TypingEventService implements ITypingEventService {
  final RethinkDb _r;
  final Connection _connection;
  var _controller = StreamController<TypeEventModel>.broadcast();
  StreamSubscription? _changeFeed;

  TypingEventService(this._r, this._connection);
  @override
  void dispose() {
    _connection.close();
    _changeFeed!.cancel();
  }

  @override
  Future<bool> sent(TypeEventModel typeEventModel) async {
    Map record = await _r.table('typing_events').insert(
        typeEventModel.toJson(), {'conflict': 'update'}).run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<TypeEventModel> subscribe(User user, List<String> usreIds) {
    _changeFeed = _r
        .table('typing_events')
        .filter((event) {
          return event('to') // return "to => user will receive message"
              .eq(user.gId) // sure "to Id" is = user.gId
              .and(_r.expr(usreIds).contains(event(
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
              })
              .catchError((error) => print('$error Error In subscribe Listen'))
              .onError((error, stackTrace) => print(error));
        });
    return _controller.stream;
  }

  TypeEventModel typeFromFeed(feedData) {
    var data = feedData['new_val'];
    return TypeEventModel.fromJson(data);
  }
}
