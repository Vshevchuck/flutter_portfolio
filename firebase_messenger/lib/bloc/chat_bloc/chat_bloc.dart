import 'package:flutter_bloc/flutter_bloc.dart';
import '../../networking/firestore.dart';
import '../../networking/push_notifications/push_notification.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// ChatBloc includes operations (sending messages and receiving messages)
/// with a branch of the database to which two users belong
/// according to the ChatroomBloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Firestore firestore = Firestore();

  @override
  get initialState => ChatEmptyState();

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    //receive ID chatroom for storing and sending messages
    if (event is GetChatId) {
      try {
        firestore.listenChatRoomById(event.chatId).listen((snapshot) async {
          add(GetReversedChat(snapshot.data()!['chat']));
        });
      } catch (e) {
        print(e);
      }
    }
    try {
      if (event is SendMessage) {
        _changeChatList(event.idChatRoom, event.messageAndAuth);
        yield ChatListState(_getNewReversedChatList(event.idChatRoom));
      }
    } catch (_) {}
    if (event is GetReversedChat) {
      var reversed = event.chat.reversed.toList();
      yield ChatListState(reversed);
    }
  }

  ///flip the chat for a better view of the message
  _getNewReversedChatList(String id) async {
    var documentUpdate = await firestore.getChatroomById(id);
    var chatUpdate = (documentUpdate.data()?['chat'] as List<dynamic>);
    return chatUpdate.reversed.toList();
  }

  ///open the message array and add a new message at the end
  ///consisting of the sender and the message itself
  void _changeChatList(String id, dynamic message) async {
    String to = '';
    var document = await firestore.getChatroomById(id);
    List<dynamic> chat = document.data()?['chat'];
    chat.add(message);
    var key;
    var messageAuth = message as Map<String, dynamic>;
    for (var item in messageAuth.entries) {
      message = item.value;
      key = item.key;
    }
    await _pushNotification(key, document, to, message);
    firestore.addNewMassageToFirestore(id, chat, message);
  }
  ///send to devise if the application is minimized
  Future<void> _pushNotification(
      String key, var document, String to, String message) async {
    var user = await firestore.getUserWithId(key);
    if (user.docs.first.get('id') == document.data()?['id_first_user']) {
      to = document.data()?['id_second_user'];
    } else {
      to = document.data()?['id_first_user'];
    }
    var userTo = await firestore.getUserWithId(to);
    await PushNotification.push(
        to: userTo.docs.first.get('device_id'),
        title: "Message from ${user.docs.first.get('name')}",
        body: message);
  }
}
