import 'package:flutter/material.dart';
import 'user_settings.dart';
import 'lottery_data_manager.dart';
import 'lottery_history.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'image_saver.dart';

void initialize() async => SharedPreference.init();

void main() {
  runApp(MyApp());
  initialize();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LotteryWinner',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: PickerPage(title: 'Picker'),
    );
  }
}

class PickerPage extends StatefulWidget {
  PickerPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _PickerPageState createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> {
  GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _loading = false;
  final LotteryDataManager _lotteryDataManager = LotteryDataManager();
  List<String> _lotteryNumbers = [];
  static const TextStyle _style =
      TextStyle(fontSize: 16.0, color: Colors.black87);

  void _pickLotteryNumbers() {
    setState(() {
      _loading = true;
    });
    _lotteryDataManager
        .pickLotteryNumbersRandomly(SharedPreference.getLotteryPickCount())
        .then((list) {
      setState(() {
        _lotteryNumbers = list;
        _loading = false;
      });
    });
  }

  void savePickedLotteryNumber(List<String> lotteryNumbers) {
    _lotteryDataManager.cachePickedLotteryNumber(lotteryNumbers);
  }

  Future<void> savePickedLotteryNumberToGallery() async {
    RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext.findRenderObject();
    var image = await boundary.toImage(pixelRatio: 1.0);
    var bytes = await image.toByteData(format: ImageByteFormat.png);
    await saveImageToGallery(bytes);
  }

  Widget listOrLoading(Function showSnackBar) {
    if (_loading) {
      return Center(child: Container(child: CircularProgressIndicator()));
    } else {
      return Stack(children: [
        RepaintBoundary(
          key: _repaintBoundaryKey,
            child: ListView.separated(
                separatorBuilder: (context, i) =>
                    Divider(color: Colors.black87),
                padding: const EdgeInsets.all(16.0),
                itemCount: _lotteryNumbers.length,
                itemBuilder: (context, i) {
                  return _buildRow(_lotteryNumbers[i]);
                })),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                      child: Text('Pick this!'),
                      onPressed: () {
                        savePickedLotteryNumber(_lotteryNumbers);
                        savePickedLotteryNumberToGallery().then(showSnackBar('Saved.'));
                      }))),
        )
      ]);
    }
  }

  bool get loading => _loading;

  Widget _buildRow(String lotteryNumber) {
    return ListTile(title: Text(lotteryNumber, style: _style));
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
          icon: Icon(Icons.history),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return LotteryHistory();
            }));
          }),
      IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return UserSettingPage();
            }));
          })
    ];
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: _buildActions(),
      ),
      body: Builder(
          builder: (context) => listOrLoading((text) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(text,
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.white))));
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickLotteryNumbers,
        tooltip: 'Pick lottery numbers',
        child: Icon(Icons.autorenew),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void _showSnackBar(BuildContext context, String text) {}
