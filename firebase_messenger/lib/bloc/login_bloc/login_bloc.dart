import 'package:firebase_messenger/bloc/login_bloc/login_event.dart';
import 'package:firebase_messenger/bloc/login_bloc/login_state.dart';
import 'package:firebase_messenger/networking/firebase_auth_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../user_bloc/user_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserLogin userLogin = UserLogin('Empty', 'Empty');

  @override
  get initialState => LoginEmptyState();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    final FirebaseAuthClient authClient = FirebaseAuthClient();
    if (event is SetInitialEvent) {
      yield LoginEmptyState();
    }
    if (event is GetUserDataEvent) {
      dynamic authStatus =
          await authClient.SignIn(event.userLogin.email, event.userLogin.password);
      if (authStatus is User) {
        yield UserLoginedState(authStatus);
      } else {
        yield LoginErrorState(_checkLoginError(event.userLogin, authStatus));
      }
    }
  }

  String _checkLoginError(UserLogin user, FirebaseAuthException e) {
    if (user.email.isEmpty || user.password.isEmpty) {
      return ('Fill in all the fields');
    }
    if (user.password.length < 6) {
      return ('password must be at least 6 characters');
    }
    if (!user.email.contains('.') || !user.email.contains('@')) {
      return ('invalid email input form , please check availability . or @');
    }
    return (e.message.toString());
  }
}
