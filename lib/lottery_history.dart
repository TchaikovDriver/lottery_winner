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
  LotteryDataManager dataManager = LotteryDataManager();
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
        ),
      ],
    );
  }

  void readLocalHistory() async {
    var list = await dataManager.lotteryHistoryList;
    setState(() {
      _isLoading = false;
      _lotteryHistory = list;
    });
  }

  String getOrderFromHistory(String history) {
    var firstSpaceIdx = history.indexOf(' ');
    return history.substring(0, firstSpaceIdx);
  }

  void requestForNewLotteryHistory() async {
    setState(() {
      _isLoading = true;
    });
    var order = int.parse(getOrderFromHistory(_lotteryHistory[0]));
    var newHistory = await dataManager.requestNewLotteryHistoryLargerThanOrder(order);
    setState(() {
      _lotteryHistory.insertAll(0, newHistory);
      _isLoading = false;
    });
    dataManager.insertLotteryNumberInHistoryFile(newHistory);
  }

  @override
  Widget build(BuildContext context) {
    readLocalHistory();
    return Scaffold(
      appBar: AppBar(title: Text('Lottery History'), actions: <Widget>[
        IconButton(icon: Icon(Icons.attach_money), onPressed: () {
          
        },)
      ],),
      body: _body(context),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.update),
          onPressed: () {
            if (_isLoading) return;
            requestForNewLotteryHistory();
          }),
    );
  }
}
