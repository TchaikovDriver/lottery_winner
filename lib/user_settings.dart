import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static SharedPreferences _sp;
  static String lotteryPickCountKey = 'PickCnt';

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
}
