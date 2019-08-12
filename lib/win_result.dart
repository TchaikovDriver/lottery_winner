import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class WinResult extends StatefulWidget {
  // xx  xx  xx  xx  xx  xx - xx
  final List<String> pickedLotteryNumbers;

  // order,xx,xx,xx,xx,xx,xx,xx
  final List<String> historyLotteryNumbers;

  WinResult(this.pickedLotteryNumbers, this.historyLotteryNumbers);

  @override
  State createState() {
    return _WinResultState(pickedLotteryNumbers, historyLotteryNumbers);
  }
}

class _WinResultState extends State<WinResult> {
  static const TextStyle _plainTextStyle = TextStyle(fontSize: 18.0);
  static const TextStyle _notHitTextStyle =
      TextStyle(fontSize: 18.0, color: Colors.black);
  static const TextStyle _hitRedTextStyle =
      TextStyle(fontSize: 18.0, color: Colors.orange);
  static const TextStyle _hitBlueTextStyle =
      TextStyle(fontSize: 18.0, color: Colors.amberAccent);
  bool _showWinResult = false;

  // xx  xx  xx  xx  xx  xx - xx
  List<String> pickedLotteryNumbers;

  // xx  xx  xx  xx  xx  xx - xx
  List<String> historyLotteryNumbers;

  TextEditingController _orderController = TextEditingController();

  _WinResultState(this.pickedLotteryNumbers, this.historyLotteryNumbers);

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
      text,
      style: _plainTextStyle,
    )));
  }

  /// 将xx  xx  xx  xx  xx  xx - xx的字符串转成int
  List<int> parseLotteryNumbers(String row) {
    var ret = row.replaceAll(RegExp(" {2}- {2}| {2}"), ",");
    return ret.split(',').map((n) => int.parse(n)).toList(growable: false);
  }

  List<int> findHistoryByOrder(int order) {
    if (order == null) return null;
    for (String history in historyLotteryNumbers) {
      var firstSpaceIdx = history.indexOf(' ');
      var curOrder = int.parse(history.substring(0, firstSpaceIdx));
      if (curOrder == order)
        return parseLotteryNumbers(history.substring(firstSpaceIdx + 2));
      else if (curOrder < order) {
        // History's largest order is less than target order, means user input
        // the wrong order or the app has not get the newest history.
        return null;
      }
    }
    return null;
  }

  List<Widget> constructPickedWidgets(BuildContext context) {
    var pickedWidgets = <Widget>[];
    if (_showWinResult) {
      var targetOrder = int.tryParse(_orderController.text);
      var targetHistory = findHistoryByOrder(targetOrder);
      if (targetHistory == null) {
        _showWinResult = false;
        Fluttertoast.showToast(msg: '找不到指定期数，请输入合法期数或更新历史数据');
        return constructPickedWidgets(context);
      }
      for (String picked in pickedLotteryNumbers) {
        var pickedNumbers = parseLotteryNumbers(picked);
        var historyNumbers = targetHistory;
        var balls = <TextSpan>[];
        var len = historyNumbers.length - 1;
        for (var i = 0; i < len; ++i) {
          // reds
          balls.add(TextSpan(
              text: '${pickedNumbers[i].toString().padLeft(2, '0')}  ',
              style: historyNumbers[i] == pickedNumbers[i]
                  ? _hitRedTextStyle
                  : _notHitTextStyle));
        }
        balls.add(TextSpan(
            text: '- ${pickedNumbers[len].toString().padLeft(2, '0')}\n',
            style: historyNumbers[len] == pickedNumbers[len]
                ? _hitBlueTextStyle
                : _notHitTextStyle));
        pickedWidgets.add(RichText(text: TextSpan(children: balls)));
      }
    } else {
      for (String picked in pickedLotteryNumbers) {
        pickedWidgets.add(Text(
          picked,
          style: _notHitTextStyle,
        ));
      }
    }
    return pickedWidgets;
  }

  Widget _body(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          children: constructPickedWidgets(context),
        ),
        Container(
            alignment: Alignment.bottomCenter,
            child: Center(
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _orderController,
                          decoration: InputDecoration(labelText: '期数'),
                          keyboardType: TextInputType.number,
                        ),
                        Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: RaisedButton(
                              onPressed: () {
                                var order = _orderController.text.trim();
                                if (order.length == 0) {
                                  _showSnackBar(context, '请输入期数!');
                                  return;
                                }
                                setState(() {
                                  _showWinResult = true;
                                });
                              },
                              child: Text('Check!'),
                            ))
                      ],
                    ))))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Win Result')),
      body: Builder(builder: (context) => _body(context)),
    );
  }
}
