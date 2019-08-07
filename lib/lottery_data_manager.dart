import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrapy/scrapy.dart';

class _LotteryNumber extends Item {
  String number;

  _LotteryNumber(this.number);

  @override
  Map<String, dynamic> toJson() {
    return {"number": number};
  }

  factory _LotteryNumber.fromJson(String str) =>
      _LotteryNumber.fromMap(json.decode(str));

  factory _LotteryNumber.fromMap(Map<String, dynamic> json) =>
      _LotteryNumber(json['number']);
}

class _LotteryNumbers extends Items {
  List<_LotteryNumber> lotteryNumbers;

  _LotteryNumbers(this.lotteryNumbers);

  factory _LotteryNumbers.fromMap(Map<String, dynamic> json) =>
      _LotteryNumbers(json['items'] == null
          ? []
          : List<_LotteryNumber>.from(
              json['items'].map((x) => _LotteryNumber.fromMap(x))));
}

class _Spider extends Spider<_LotteryNumber, _LotteryNumbers> {



  @override
  Stream<String> parse(Response result) async* {
    var document = html.parse(result.body);
    var preNode = document.querySelector("pre");
    yield result.body;
  }

  @override
  Stream<String> transform(Stream<String> parsed) async* {
    await for (String p in parsed) {
      yield p;
    }
  }

  @override
  Stream<_LotteryNumber> save(Stream<String> transformed) async* {
    await for (String t in transformed) {
      var lotteryNumber = _LotteryNumber(t);
      yield lotteryNumber;
    }
  }
}

/// Responsible for lottery numbers picking and storing history lottery numbers.
///
class LotteryDataManager {
  static final String pickUrl =
      "https://www.random.org/quick-pick/?lottery=6x33.1x16&tickers=";

  const LotteryDataManager();

  Future<List<String>> pickLotteryNumbersRandomly(int count) async {
    var url = pickUrl + count.toString();
    var spider = _Spider();
    spider.name = 'mySpider';
    spider.client = Client();
    spider.startUrls = [url];
    spider.path = await getExternalFilePath("test.txt");
    await spider.startRequests();
    await spider.saveResult();
    print('write file done');
//    var response = await http.get(url, headers: header);
//    writeDataIntoFile(response.data, "test.txt");
//    var html = xml.parse(response.data);
//    var data = html.findAllElements('pre').first.text.split('\n');
//    return data;
    return [];
  }

  Future<String> getExternalFilePath(String fileName) async {
    var dir = await getExternalStorageDirectory();
    var file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
    return file.path;
  }

  void writeDataIntoFile(String data, String fileName) async {
    var dir = await getExternalStorageDirectory();
    var file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
    file.writeAsString(data);
    print('File written to ${file.path}');
  }
}
