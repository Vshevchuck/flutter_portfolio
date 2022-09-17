import 'package:firebase_messenger/bloc/register_bloc/register_event.dart';
import 'package:firebase_messenger/bloc/register_bloc/register_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_model.dart';
import '../../networking/firebase_auth_client.dart';

///Register the user and checks the information entered in the fields
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  @override
  get initialState => RegisterEmptyState();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is SetInitialRegisterEvent) {
      yield RegisterEmptyState();
    }
    if (event is GetUserDataEvent) {
      final FirebaseAuthClient authClient = FirebaseAuthClient();
      dynamic authStatus = await authClient.SignUp(event.userRegister.email,
          event.userRegister.password, event.userRegister.name ?? "");
      if (authStatus is User) {
        yield UserRegisteredState(authStatus);
      } else {
        yield RegisterErrorState(_checkRegisterError(event.userRegister, authStatus));
      }
    }
  }

  String _checkRegisterError(
      UserAuth user, FirebaseAuthException exception) {
    if (user.password.length < 6) {
      return ('password must be at least 6 characters');
    }
    if (user.email.isEmpty || user.password.isEmpty || user.name=="") {
      return ('Fill in all the fields');
    }
    if (!user.email.contains('.') || !user.email.contains('@')) {
      return ('invalid email input form , please check availability . or @');
    }
    return (exception.message.toString());
  }
}
