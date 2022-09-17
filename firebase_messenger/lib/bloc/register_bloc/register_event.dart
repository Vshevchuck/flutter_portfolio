import 'package:firebase_messenger/models/user_model.dart';

class RegisterEvent{}


class SetInitialRegisterEvent extends RegisterEvent{}
class GetUserDataEvent extends RegisterEvent {
  final UserAuth userRegister;
  GetUserDataEvent(this.userRegister);
}
