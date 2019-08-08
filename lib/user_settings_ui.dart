part of 'user_settings.dart';

class UserSettingPage extends StatelessWidget {
  final TextEditingController _fixedLotteryNumberController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    _fixedLotteryNumberController.text = SharedPreference.getFixedLotteryNumber();
    return Scaffold(
        appBar: AppBar(
          title: Text('User Settings'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        'Fix numbers',
                        style: const TextStyle(fontSize: 16.0),
                      ))),
              Padding(
                  padding: EdgeInsets.only(left: 18.0, right: 18.0),
                  child: TextField(
                    controller: _fixedLotteryNumberController,
                    decoration: InputDecoration(
                        labelText: '固定号码',
                        helperText: 'xx xx xx xx xx xx - xx'),
                    autofocus: false,
                  )),
              Expanded(
                  child: SafeArea(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: RaisedButton(
                                child: Text('Save'),
                                onPressed: () {
                                  _saveFixedLotteryNumber();
                                  Navigator.pop(context);
                                }),
                          ))))
            ],
          ),
        ));
  }

  void _saveFixedLotteryNumber() {
    SharedPreference.setFixedLotteryNumber(_fixedLotteryNumberController.text);
  }
}
