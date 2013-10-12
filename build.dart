
import 'package:polymer/builder.dart';     

main() {     
  build( entryPoints: ['web/test_polymer.html', 'web/index.html']).then(  (v)=> deploy(entryPoints: ['web/test_polymer.html', 'web/index.html']));
}