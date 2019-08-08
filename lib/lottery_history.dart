import 'package:flutter/material.dart';
import 'lottery_data_manager.dart';

class LotteryHistory extends StatefulWidget {
  @override
  State createState() {
    return _LotteryHistoryState();
  }
}

class _LotteryHistoryState extends State<LotteryHistory> {
  bool _isLoading = true;
  List<String> _lotteryHistory = [];
  static const TextStyle _style = TextStyle(fontSize: 18.0);

  Widget _body(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: ListView.separated(
            separatorBuilder: (context, i) {
              return Divider();
            },
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(_lotteryHistory[i], style: _style),
              );
            },
            itemCount: _lotteryHistory.length,
          ),
        ),
        Offstage(
          child: Center(
            child: CircularProgressIndicator(),
          ),
          offstage: !_isLoading,
        )
      ],
    );
  }

  void readLocalHistory() async {
    var list = await LotteryDataManager().lotteryHistoryList;
    setState(() {
      _isLoading = false;
      _lotteryHistory = list;
    });
  }

  void requestForNewLotteryHistory() async {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    readLocalHistory();
    return Scaffold(
      appBar: AppBar(title: Text('Lottery History')),
      body: _body(context),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.update),
          onPressed: () {
            requestForNewLotteryHistory();
          }),
    );
  }
}
