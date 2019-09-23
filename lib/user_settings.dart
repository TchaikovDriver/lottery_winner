import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
part 'user_settings_ui.dart';


class SharedPreference {
  static SharedPreferences _sp;
  static const String _lotteryPickCountKey = 'PickCnt';
  static const String _fixedLotteryNumberKey = "FixedLot";
  static const String _pickedLotteryNumberKey = 'PickedLot';
  static const String _useFixedMode = "useFixedMode";

  static void init() async {
    if (_sp != null) return;
    _sp = await SharedPreferences.getInstance();
  }

  static int getLotteryPickCount({int defaultCount: 5}) {
    var ret = _sp.get(_lotteryPickCountKey);
    return ret == null ? defaultCount : ret;
  }

  static void setLotteryPickCount(int count) {
    if (count <= 0) throw 'Count must be positive!';
    _sp.setInt(_lotteryPickCountKey, count);
  }

  static String getFixedLotteryNumber({String defaultVal: "01  08  13  19  24  29  -  05"}) {
    var ret = _sp.get(_fixedLotteryNumberKey);
    return ret == null ? defaultVal : ret;
  }

  static void setFixedLotteryNumber(String value) {
    _sp.setString(_fixedLotteryNumberKey, value);
  }

  static void setPickedLotteryNumber(String lotteryNumbers) {
    _sp.setString(_pickedLotteryNumberKey, lotteryNumbers);
  }

  static String getPickedLotteryNumber() {
    var ret = _sp.getString(_pickedLotteryNumberKey);
    return ret == null ? "" : ret;
  }

  static void setUseFixedMode(bool fixed) {
    _sp.setBool(_useFixedMode, fixed);
  }

  static bool getUseFixedMode() {
    var ret = _sp.getBool(_useFixedMode);
    return ret == null ? false : ret;
  }
}
