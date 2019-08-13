import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

Future<String> saveImageToGallery(ui.Image img) async {
  try {
    return await _saveImageToGalleryInner(img);
  } on FileSystemException {
    return null;
  }
}

Future<String> _saveImageToGalleryInner(ui.Image uiImg) async {
  var bytes = await uiImg.toByteData(format: ui.ImageByteFormat.rawRgba);
  print(bytes.buffer.asUint8List());
  var img = Image.fromBytes(uiImg.width, uiImg.height, bytes.buffer.asUint8List());
  var outputBytes = encodeJpg(img);
  var now = DateTime.now();
  var fileName = '${now.millisecondsSinceEpoch}.jpg';
  var dirPath = (await getExternalStorageDirectory()).path + "/Pictures/";
  var directory = Directory(dirPath);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  var file = File(dirPath + fileName);
  file.writeAsBytesSync(outputBytes, mode: FileMode.write, flush: true);
  return file.path;
}
