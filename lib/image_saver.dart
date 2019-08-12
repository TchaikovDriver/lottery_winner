import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';

Future<bool> saveImageToGallery(ByteData bytes) async {
  final result = await ImageGallerySaver.save(bytes.buffer.asUint8List());
  print(result.toString());
  return true;
}