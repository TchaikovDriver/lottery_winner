import 'dart:io';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'user_settings.dart' show SharedPreference;

/// Responsible for lottery numbers picking and storing history lottery numbers.
class LotteryDataManager {
  static const String pickUrl =
      "https://www.random.org/quick-pick/?lottery=6x33.1x16&tickets=";
  static const String historyLotteryFileName = "history.txt";

  Set<String> _lotteryHistorySet;
  List<String> _lotteryHistoryList;

  LotteryDataManager();

  Future<void> _initHistoryData() async {
    _lotteryHistorySet = Set();
    var history = await rootBundle.loadString('assets/history_lottery.txt');
    for (var i = 0, lastIdx = 0, len = history.length; i < len; ++i) {
      if (history[i] == '\n') {
        var line = history.substring(lastIdx, i);
        var firstCommaIdx = line.indexOf(',');
        var order = line.substring(0, firstCommaIdx);
        var lottery = line.substring(firstCommaIdx + 1, line.length);
        if (_lotteryHistorySet.contains(lottery)) {
          print('Order $order : $lottery appears at least twice!');
        } else {
          _lotteryHistorySet.add(lottery);
        }
        lastIdx = i + 1;
      }
    }
  }

  Future<List<String>> get lotteryHistoryList async {
    if (_lotteryHistoryList == null) {
      _lotteryHistoryList = [];
      var history = await rootBundle.loadString('assets/history_lottery.txt');
      for (var i = 0, lastIdx = 0, len = history.length; i < len; ++i) {
        if (history[i] == '\n') {
          var line = history.substring(lastIdx, i).trimRight();
          var lastCommaIdx = line.lastIndexOf(',');
          line = line.substring(0, line.lastIndexOf(',')).replaceAll(",", "  ") + "  -  " + line.substring(lastCommaIdx + 1);
          _lotteryHistoryList.add(line);
          lastIdx = i + 1;
        }
      }
    }
    return _lotteryHistoryList;
  }

  Future<Set<String>> _getLotteryHistory() async {
    if (_lotteryHistorySet != null) return _lotteryHistorySet;
    await _initHistoryData();
    return _lotteryHistorySet;
  }

  Future<List<String>> requestRandomLotteryNumbers(int count) async {
    var url = pickUrl + count.toString();
    var header = {
      "accept": "text/html",
      'referer': url,
      "sec-fetch-mode": "navigate",
      "sec-fetch-site": "origin",
      "sec-fetch-user": "?1",
      "upgrade-insecure-requests": "1",
      "user-agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36",
    };
    var response = await http.get(url, headers: header);
    if (response.statusCode == 200) {
      var document = html.parse(response.body);
      var data = document
          .querySelector("pre")
          .innerHtml;
      return data.split('\n');
    } else {
      return [];
    }
  }

  Future<List<String>> pickLotteryNumbersRandomly(int count) async {
    var data = await requestRandomLotteryNumbers(count);
    if (data.length == 0) return data;
    var historySet = await _getLotteryHistory();
    var ret = <String>[];
    for (String line in data) {
      if (line.length == 0) continue;
      line = line.replaceAll(RegExp("\-|\/"), ",");
      line = line.replaceAll(" ", "");
      if (!historySet.contains(line)) {
        print(line);
        var lastCommaIdx = line.lastIndexOf(',');
        line = line.substring(0, lastCommaIdx).replaceAll(',', '  ') + '  -  ' + line.substring(lastCommaIdx + 1, line.length);
        ret.add(line);
      }
    }
    var fixedLotteryNumber = SharedPreference.getFixedLotteryNumber();
    ret.insert(0, fixedLotteryNumber);
    return ret.sublist(0, 5 > ret.length ? ret.length : 5);
  }

  Future<File> _createFileByPath(Directory dir, String fileName) async {
    var file = File('${dir.path}/$fileName');
    if (await file.exists()) await file.delete();
    return file;
  }

  Future<File> _getHistoryLotteryFile(String fileName) async {
    var dir = await getTemporaryDirectory();
    var file = await _createFileByPath(dir, fileName);
    return file;
  }

  Future<String> _getExternalFilePath(String fileName) async {
    var dir = await getExternalStorageDirectory();
    var file = await _createFileByPath(dir, fileName);
    return file.path;
  }

  void _writeDataIntoFile(String data, String fileName) async {
    var dir = await getExternalStorageDirectory();
    var file = await _createFileByPath(dir, fileName);
    file.writeAsString(data);
    print('File written to ${file.path}');
  }
}
