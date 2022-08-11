import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reach_core/core/theme/colors.dart';

const myMessageOutterPadding = EdgeInsets.fromLTRB(30, 2, 10, 2);
const peerMessagePadding = EdgeInsets.fromLTRB(10, 2, 30, 2);

const messageInnerPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 8);

final messageTextFieldDecoration = InputDecoration(
  fillColor: Colors.white,
  hintText: 'msg'.tr,
  labelStyle: const TextStyle(fontSize: 12),
  hintStyle: const TextStyle(fontSize: 12),
  alignLabelWithHint: true,
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: darkBlue, width: 2.0),
    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
  ),
);
