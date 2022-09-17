import 'package:firebase_messenger/bloc/chat_room_bloc/chat_room_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../networking/firestore.dart';
import 'chat_room_state.dart';

///ChatRoomBloc check availability chat room and creates a new room for two users
///if the room has not yet been created
class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final Firestore firestore = Firestore();

  @override
  get initialState => ChatRoomEmptyState();

  @override
  Stream<ChatRoomState> mapEventToState(ChatRoomEvent event) async* {
    bool newRoom = true;
    String id = '';
    if (event is CreateChatRoomEvent) {
      id = await _addChat(event.OurId, event.IdSecondUser);
      firestore.listenUsers().listen((snapshot) {
        for (int i = snapshot.docs.length - 1; i >= 0; i--) {
          if (snapshot.docs[i].get('id') == event.OurId) {
            _addChatToUser(id, event.IdSecondUser, snapshot, i);
          }
          if (snapshot.docs[i].get('id') == event.IdSecondUser) {
            _addChatToUser(id, event.OurId, snapshot, i);
          }
        }
      });
      yield ChatRoomIdState(id);
    } else if (event is FindChatRoomEvent) {
      _findUserChatRooms(event.ourUser.uid, event.secondUser.id);
    } else if (event is GetChatRoomEvent && event.chatroom.isEmpty) {
      yield ChatRoomNewState();
    } else if (event is GetChatRoomEvent) {
      for (var item in event.chatroom.entries) {
        if (item.value == event.secondUserId) {
          newRoom = false;
          yield ChatRoomIdState(item.key);
        }
      }
      if (newRoom) {
        yield ChatRoomNewState();
      }
    }
  }

  ///check the visibility of the chat room
  void _findUserChatRooms(String loginedUserId, String secondUserId) {
    firestore.listenUserbyId(loginedUserId).listen((snapshot) {
      add(GetChatRoomEvent(snapshot.docs.first.get('chatrooms'), secondUserId));
    });
  }

  ///add created chat to the user's chat list
  void _addChatToUser(String id, String secondUser,
      QuerySnapshot<Map<String, dynamic>> snapshot, int i) {
    Map<String, dynamic> chatrooms =
        snapshot.docs[i].get('chatrooms') as Map<String, dynamic>;
    chatrooms.addAll({id: secondUser});
    firestore.addChatToUser(snapshot, i, chatrooms);
  }

  ///add new chat to firestore data base
  Future<String> _addChat(String ourId, String idSecondUser) async {
    String id = '';
    await firestore
        .addChat(ourId, idSecondUser)
        .then((value) => ((id = value.id)));
    return id;
  }
}
