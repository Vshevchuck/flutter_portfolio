import 'dart:async';

import 'package:firebase_messenger/bloc/login_bloc/login_event.dart';
import 'package:firebase_messenger/pages/login_page/widgets/dialog_builder_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/login_bloc/login_bloc.dart';
import '../../../bloc/login_bloc/login_state.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../models/user_model.dart';
import '../../../util/decorations/decorations.dart';
import '../login_page.dart';

class SignInButtonWidget extends StatelessWidget {
  static const double widthButton=300;
  const SignInButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.locale;
    final LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);
    BlocProvider.of<LoginBloc>(context).initialState;
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      if (state is UserLoginedState) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context)
              .pushReplacementNamed('/main', arguments: state.user);
        });
      }
      if (state is LoginErrorState) {
        loginBloc.add(SetInitialEvent());
        LoginPageState.message = state.message;
        scheduleMicrotask(() => Navigator.of(context)
            .restorablePush(ShowMessage.dialogBuilderWidget));
      }
      return Container(
        decoration: Decorations.buttonDecoration,
        child: SizedBox(
          width: widthButton,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.transparent,
              onSurface: Colors.transparent,
              shadowColor: Colors.transparent,),
            onPressed: () async {
              UserLogin userModel = UserLogin(
                  LoginPageState.emailController.text,
                  LoginPageState.passwordController.text);
              loginBloc.add(GetUserDataEvent(userModel));
              LoginPageState.emailController.text = "";
              LoginPageState.passwordController.text = "";
            },
            child: Text(LocaleKeys.Sign_In.tr()),
          ),
        ),
      );
    });
  }
}
