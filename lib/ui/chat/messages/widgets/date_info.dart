import 'package:flutter/material.dart';
import 'package:reach_core/core/theme/theme.dart';

class DateInfo extends StatelessWidget {
  const DateInfo({
    Key? key,
    required this.date,
  }) : super(key: key);

  final String date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding8,
        child: Text(date, style: titleSmallBold),
      ),
    );
  }
}
