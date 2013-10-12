library app_bootstrap;

import 'package:polymer/polymer.dart';
import 'dart:mirrors' show currentMirrorSystem;

import 'doto_list_element.dart' as i0;
import 'doto.dart' as i1;

void main() {
  initPolymer([
      'doto_list_element.dart',
      'doto.dart',
    ], currentMirrorSystem().isolate.rootLibrary.uri.toString());
}
