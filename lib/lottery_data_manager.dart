import 'dart:io';
import 'dart:convert';

import 'package:html/parser.dart' as html;
import 'package:html/dom.dart';
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

  /// 加载LotteryHistory文件，会先从cache目录中找，如果找不到，就从assets里加载，
  /// 加载后会在cache目录下创建文件写一遍。将整个文件内容读取成String并返回。
  Future<String> _loadLotteryHistoryFileContent() async {
    var cacheFile = await _createFileByPath(
        await getTemporaryDirectory(), historyLotteryFileName, deleteIfExits: false);
    var history;
    if (await cacheFile.exists()) {
      print(cacheFile.path);
      history = cacheFile.readAsStringSync();
    } else {
      history = await rootBundle.loadString('assets/history_lottery.txt');
      cacheFile.writeAsStringSync(history);
    }
    return history;
  }

  Future<void> _initHistoryData() async {
    _lotteryHistorySet = Set();
    var history = await _loadLotteryHistoryFileContent();
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

  /// 读取assets中的history_lottery.txt
  Future<List<String>> get lotteryHistoryList async {
    if (_lotteryHistoryList == null) {
      _lotteryHistoryList = [];
      var history = await _loadLotteryHistoryFileContent();
      for (var i = 0, lastIdx = 0, len = history.length; i < len; ++i) {
        if (history[i] == '\n') {
          var line = history.substring(lastIdx, i).trimRight();
          var lastCommaIdx = line.lastIndexOf(',');
          line =
              line.substring(0, line.lastIndexOf(',')).replaceAll(",", "  ") +
                  "  -  " +
                  line.substring(lastCommaIdx + 1);
          _lotteryHistoryList.insert(0, line);
          lastIdx = i + 1;
        }
      }
    }
    return _lotteryHistoryList;
  }

  /// 从网页里爬最新的历史数据，并把数据以order,xx,xx,xx,xx,xx,xx,xx的String形式返回
  /// 当爬到的数据order == [minOrder]时，会停止遍历，因为后边的都已经存在了。
  Future<List<String>> requestNewLotteryHistoryLargerThanOrder(
      final int minOrder) async {
    const header = {"Referer": "http://www.cwl.gov.cn/kjxx/ssq/kjgg/"};
    var response = await http.get(
        "http://www.cwl.gov.cn/cwl_admin/kjxx/findDrawNotice?name=ssq&issueCount=30",
        headers: header);
    var ret = <String>[];
    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      List<dynamic> resultList = res['result'];
      for (Map<String, dynamic> history in resultList) {
        var order = int.parse(history['code']);
        if (order <= minOrder) break;
        ret.add(history['code'] + ',' + history['red'] + ',' + history['blue']);
      }
    } else {
      print('request failed: ' + response.statusCode.toString());
    }
    return ret;
  }

  /// 插入新的LotteryHistory到历史文件尾部，数据按照order升序排列
  /// [newLotteryHistory]的数据是按order降序的，所以要反向遍历
  Future<void> insertLotteryNumberInHistoryFile(
      List<String> newLotteryHistory) async {
    var file = await _createFileByPath(
        await getTemporaryDirectory(), historyLotteryFileName, deleteIfExits: false);
    var sink = file.openWrite(mode: FileMode.append);
    for (var i = newLotteryHistory.length - 1; i >= 0; --i) {
      sink.writeln(newLotteryHistory[i]);
    }
    sink..flush()..close();
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
      var data = document.querySelector("pre").innerHtml;
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
        line = line.substring(0, lastCommaIdx).replaceAll(',', '  ') +
            '  -  ' +
            line.substring(lastCommaIdx + 1, line.length);
        ret.add(line);
      }
    }
    var fixedLotteryNumber = SharedPreference.getFixedLotteryNumber();
    ret.insert(0, fixedLotteryNumber);
    return ret.sublist(0, 5 > ret.length ? ret.length : 5);
  }

  void cachePickedLotteryNumber(List<String> lotteryNumbers) {
    var sb = StringBuffer();
    for (var i = 0, len = lotteryNumbers.length; i < len; ++i) {
      sb.write(lotteryNumbers[i]);
      if (i != len - 1) {
        sb.write("|");
      }
    }
    SharedPreference.setPickedLotteryNumber(sb.toString());
  }

  List<String> getPickedLotteryNumber() {
    var cache = SharedPreference.getPickedLotteryNumber();
    if (cache.length == 0) return [];
    return cache.split('|');
  }

  Future<File> _createFileByPath(Directory dir, String fileName, {bool deleteIfExits=true}) async {
    var file = File('${dir.path}/$fileName');
    if (deleteIfExits && await file.exists()) await file.delete();
    return file;
  }
}
