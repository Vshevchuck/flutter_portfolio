import 'dart:async';

import 'package:firebase_messenger/bloc/user_bloc/user_event.dart';
import 'package:firebase_messenger/bloc/user_bloc/user_state.dart';
import 'package:firebase_messenger/networking/firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../generated/locale_keys.g.dart';
import '../../models/user_model.dart';

///UserBloc is responsible for loading and displaying currently registered users
class UserBloc extends Bloc<UserEvent, UserState> {
  final Firestore firestore = Firestore();
  String id = '';
  bool timeUpdate = true;

  @override
  get initialState => UserLoadingState();

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is UserLogOutEvent) {
      await FirebaseAuth.instance.signOut();
      yield UserLogOutState();
    }
    if (event is UserLoadingEvent) {
      firestore.checkLastMessageAndGetListUsers().listen((snapshot) async {
        add(UserLoadedEvent((await firestore.getUsers()).docs));});
      id = event.userID;
    }
    if (event is UserLoadedEvent) {
      List<dynamic> usersAndLastMessage = <dynamic>[];
      try {
        for (int i = 0; i < event.docs.length; i++) {
          String lastMessage = LocaleKeys.You_did_not_start_dialog.tr();
          UserModel userInList = UserModel.fromJson(event.docs[i].data());
          var getLastMessage = await firestore.getChatroomWithId('$id-${userInList.id}');
          if (getLastMessage.docs.isNotEmpty) {
            lastMessage = getLastMessage.docs.first.get('lastMessage');
          } else {
            getLastMessage = await firestore.getChatroomWithId('${userInList.id}-$id');
            if (getLastMessage.docs.isNotEmpty) {
              lastMessage = getLastMessage.docs.first.get('lastMessage');
            }
          }
          usersAndLastMessage.add([userInList, lastMessage]);
        }
        yield UserLoadedState(usersAndLastMessage);
      } catch (_) {}
    }
  }
}
