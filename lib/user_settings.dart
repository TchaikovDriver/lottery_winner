import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
part 'user_settings_ui.dart';


class SharedPreference {
  static SharedPreferences _sp;
  static const String lotteryPickCountKey = 'PickCnt';
  static const String fixedLotteryNumberKey = "FixedLot";
  static const String pickedLotteryNumberKey = 'PickedLot';

  static void init() async {
    if (_sp != null) return;
    _sp = await SharedPreferences.getInstance();
  }

  static int getLotteryPickCount({int defaultCount: 5}) {
    var ret = _sp.get(lotteryPickCountKey);
    return ret == null ? defaultCount : ret;
  }

  static void setLotteryPickCount(int count) {
    if (count <= 0) throw 'Count must be positive!';
    _sp.setInt(lotteryPickCountKey, count);
  }

  static String getFixedLotteryNumber({String defaultVal: "01  08  13  19  24  29  -  05"}) {
    var ret = _sp.get(fixedLotteryNumberKey);
    return ret == null ? defaultVal : ret;
  }

  static void setFixedLotteryNumber(String value) {
    _sp.setString(fixedLotteryNumberKey, value);
  }

  static void setPickedLotteryNumber(String lotteryNumbers) {
    _sp.setString(pickedLotteryNumberKey, lotteryNumbers);
  }

  static String getPickedLotteryNumber() {
    var ret = _sp.getString(pickedLotteryNumberKey);
    return ret == null ? "" : ret;
  }
}
