import 'package:flutter/material.dart';
import 'lottery_data_manager.dart';

class WinResult extends StatelessWidget {
  List<String> pickedLotteryNumbers;

  WinResult(this.pickedLotteryNumbers);

  Widget _body(BuildContext context) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Win Result')),
      body: _body(context),
    );
  }
}