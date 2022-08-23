import 'package:firebase_messenger/util/colors/colors_style.dart';
import 'package:flutter/material.dart';

import '../../../util/text_styles/text_styles.dart';

class MessageWidget extends StatelessWidget {
  final String userId;
  final String auth;
  final String message;

  const MessageWidget(
      {Key? key,
      required this.userId,
      required this.auth,
      required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(
        alignment: auth == userId ? Alignment.topRight : Alignment.topLeft,
        child: FittedBox(
          clipBehavior: Clip.hardEdge,
          child: Container(
              alignment:
                  auth == userId ? Alignment.topRight : Alignment.topLeft,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: auth == userId
                      ? ColorStyle.ourMessageColor
                      : ColorStyle.messageColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Text(
                        softWrap: true,
                        message,
                        style: TextStyles.messageTextStyle)),
              )),
        ),
      ),
    );
  }
}
