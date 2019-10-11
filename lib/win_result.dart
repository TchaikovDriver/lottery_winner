import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      const TextStyle(fontSize: 18.0, color: Colors.black);
  static const TextStyle _hitRedTextStyle =
      const TextStyle(fontSize: 18.0, color: Colors.orange);
  static const TextStyle _hitBlueTextStyle =
      const TextStyle(fontSize: 18.0, color: Colors.amberAccent);
  static const TextStyle _prizeTextStyle = const TextStyle(
      fontSize: 18.0,
      backgroundColor: Colors.orangeAccent,
      color: Colors.white);

  bool _showWinResult = false;
  String _currentOrderLottery = "";

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

  String _findHistoryByOrder(int order) {
    if (order == null) return null;
    for (String history in historyLotteryNumbers) {
      var firstSpaceIdx = history.indexOf(' ');
      var curOrder = int.parse(history.substring(0, firstSpaceIdx));
      if (curOrder == order)
        return history;
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
    if (this.historyLotteryNumbers.isNotEmpty &&
        _orderController.text.isEmpty) {
      var firstHistory = this.historyLotteryNumbers[0];
      var order = firstHistory.split(" ")[0];
      _orderController.text = order;
    }
    if (_showWinResult) {
      var targetOrder = int.tryParse(_orderController.text);
      var targetHistory = _findHistoryByOrder(targetOrder);
      if (targetHistory == null) {
        _showWinResult = false;
        Fluttertoast.showToast(msg: '找不到指定期数，请输入合法期数或更新历史数据');
        return constructPickedWidgets(context);
      }
      _currentOrderLottery =
          targetHistory.substring(targetHistory.indexOf(" "));
      for (String picked in pickedLotteryNumbers) {
        var balls = <TextSpan>[];
        var principle = _WinPrinciple(targetHistory);
        var lotteryResult = principle.checkResult(picked);
        var len = lotteryResult.numbers.length - 1;
        for (var i = 0; i < len; ++i) {
          // reds
          balls.add(TextSpan(
              text:
                  '${lotteryResult.numbers[i].number.toString().padLeft(2, '0')}  ',
              style: lotteryResult.numbers[i].hit
                  ? _hitRedTextStyle
                  : _notHitTextStyle));
        }
        balls.add(TextSpan(
            text:
                '- ${lotteryResult.numbers[len].number.toString().padLeft(2, '0')}  ',
            style: lotteryResult.numbers[len].hit
                ? _hitBlueTextStyle
                : _notHitTextStyle));
        balls.add(TextSpan(
            text: ' ${lotteryResult.prize} \n', style: _prizeTextStyle));
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
        Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Column(
              children: constructPickedWidgets(context),
            )),
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
                          child: Text(_currentOrderLottery,
                              style: _plainTextStyle),
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
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0, bottom: 0.0),
                          child: Column(
                            children: _buildAwardColumns(),
                          ),
                        ),
                        RaisedButton(
                          child: Text(
                            "Rule",
                          ),
                          onPressed: () {
                            showRule(context);
                          },
                        )
                      ],
                    ))))
      ],
    );
  }

  void showRule(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Rule"),
            children: _buildRuleDialogOptions(),
          );
        });
  }

  List<Widget> _buildRuleDialogOptions() {
    const plainTextStyle = TextStyle(color: Colors.black, fontSize: 16.0);
    var rule = [
      // 第0位：奖项，第1位：红球数，第2位：蓝球数
      [1, 6, 1],
      [2, 6, 0],
      [3, 5, 1],
      [4, 5, 0],
      [4, 4, 1],
      [5, 4, 0],
      [5, 3, 1],
      [6, 2, 1],
      [6, 1, 1],
      [6, 1, 0]
    ];
    var widgets = <Widget>[];
    var curPrize = 1;
    for (var list in rule) {
      if (curPrize != list[0]) {
        widgets.add(Divider(
          color: Colors.black,
        ));
        curPrize = list[0];
      }
      widgets.add(SimpleDialogOption(
          child: RichText(
        text: TextSpan(
            text: "Prize ${list[0]}:  ",
            style: plainTextStyle,
            children: _buildRuleDialogOptionText(list[1], list[2])),
      )));
    }
    return widgets;
  }

  List<TextSpan> _buildRuleDialogOptionText(int red, int blue) {
    var ret = <TextSpan>[];
    if (red > 0) {
      ret.add(TextSpan(
          text: "$red Red ", style: const TextStyle(color: Colors.red)));
    }
    if (blue > 0) {
      if (red > 0) {
        ret.add(TextSpan(
            text: "and ", style: const TextStyle(color: Colors.black)));
      }
      ret.add(TextSpan(
          text: "$blue Blue", style: const TextStyle(color: Colors.blue)));
    }
    return ret;
  }

  List<Widget> _buildAwardColumns() {
    var ret = <Widget>[];
    var spans = _buildAwardList();
    var i = 0;
    while (i < spans.length) {
      ret.add(SizedBox(
          width: 250.0,
          height: 50.0,
          child: Stack(children: <Widget>[
            Positioned(left: 0, child: RichText(text: spans[i])),
            Positioned(right: 0, child: RichText(text: spans[i + 1]))
          ])));
      i += 2;
    }
    return ret;
  }

  List<InlineSpan> _buildAwardList() {
    var awardList = <String>[
      "MAXIMUM: ￥5,000,000　",
      "MAXIMUM: ￥1,500,000　",
      "ACTUALLY: ￥3000　",
      "ACTUALLY: ￥200　",
      "ACTUALLY: ￥10　",
      "ACTUALLY: ￥5　",
    ];
    int i = 1;
    var ret = <InlineSpan>[];
    for (String line in awardList) {
      var cols = line.split(" ");
      ret.add(TextSpan(text: cols[0], style: _notHitTextStyle));
      ret.add(TextSpan(text: cols[1], style: _notHitTextStyle, children: [
        TextSpan(text: " " + i.toString() + " ", style: _prizeTextStyle)
      ]));
      ++i;
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Win Result')),
      body: Builder(builder: (context) => _body(context)),
    );
  }
}

class _LotteryResult {
  List<_LotteryToken> numbers;

  /// Represents which prize do the numbers hit, varies from 0 - 6, 0 means
  /// nothing
  int prize;

  _LotteryResult(this.numbers, this.prize);
}

class _LotteryToken {
  int number;
  bool hit;

  _LotteryToken(this.number, this.hit);
}

class _WinPrinciple {
  Set<int> _historyRedBalls;
  int _historyBlueBall;

  /// [historyNumbers] should be in form : xx  xx  xx  xx  xx  xx  -  xx
  _WinPrinciple(String historyNumbers) {
    var indexOfHyphen = historyNumbers.lastIndexOf('-');
    _historyRedBalls = _parseLotteryRedBallsToSet(
        historyNumbers.substring(0, indexOfHyphen - 2));
    _historyBlueBall = int.parse(historyNumbers.substring(indexOfHyphen + 2));
  }

  int _resolvePrize(int redHitCount, int blueHitCount) {
    if (blueHitCount == 0) {
      switch (redHitCount) {
        case 4:
          return 5;
        case 5:
          return 4;
        case 6:
          return 2;
        default:
          break;
      }
    } else {
      if (redHitCount < 3) return 6;
      switch (redHitCount) {
        case 3:
          return 5;
        case 4:
          return 4;
        case 5:
          return 3;
        case 6:
          return 1;
        default:
          break;
      }
    }
    return 0;
  }

  /// [lotteryNumbers] should be in form : xx  xx  xx  xx  xx  xx  -  xx
  _LotteryResult checkResult(String lotteryNumbers) {
    var lotteryNumberList = _parseLotteryNumbers(lotteryNumbers);
    var len = lotteryNumberList.length - 1;
    var numbers = <_LotteryToken>[];
    var redHitCount = 0;
    for (var i = 0; i < len; ++i) {
      if (_historyRedBalls.contains(lotteryNumberList[i])) {
        numbers.add(_LotteryToken(lotteryNumberList[i], true));
        ++redHitCount;
      } else {
        numbers.add(_LotteryToken(lotteryNumberList[i], false));
      }
    }
    numbers.add(_LotteryToken(
        lotteryNumberList[len], _historyBlueBall == lotteryNumberList[len]));
    return _LotteryResult(
        numbers,
        _resolvePrize(
            redHitCount, _historyBlueBall == lotteryNumberList[len] ? 1 : 0));
  }

  List<int> _parseLotteryNumbers(String lotteryNumbers) {
    var ret = lotteryNumbers.replaceAll(RegExp(" {2}- {2}| {2}"), ",");
    return ret.split(',').map((n) => int.parse(n)).toList(growable: false);
  }

  Set<int> _parseLotteryRedBallsToSet(String row) {
    var ret = row.replaceAll(RegExp(" {2}"), ",");
    return ret.split(',').map((n) => int.parse(n)).toSet();
  }
}
