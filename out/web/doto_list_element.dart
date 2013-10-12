library doto_list_element;
import 'package:polymer/polymer.dart';
import "dart:html";
import "dart:convert";import "dart:async";
import 'package:html5_dnd/html5_dnd.dart';

@CustomTag('doto-list-element')
class TodoListElement extends PolymerElement with ChangeNotifierMixin {
  Map __$url = {};
  Map get url => __$url;
  set url(Map value) {
    __$url = notifyPropertyChange(const Symbol('url'), __$url, value);
  }
  
  DropzoneGroup dropGroup;
  DraggableGroup dragGroup ;
  load_data() {
    HttpRequest.getString("/list").then( (data) {
      url=new JsonDecoder(null).convert(data);
// Install draggables (documents).
      if (url.isNotEmpty) { 
        var q=this.shadowRoot.query('.trash');
        if (q != null) {
         dragGroup..installAll(queryAll('.url'));
         dropGroup..install(q)
           ..accept.add(dragGroup)
             ..onDrop.listen((DropzoneEvent event) {
               event.draggable.remove();
               event.dropzone.classes.add('full');
             });
        } else {
          print ("no d&g");
        }

      }
      new Timer(new Duration(seconds: 1), load_data);
    });
    
  }
  TodoListElement() {
    
  
// Install dropzone (trash).
   
      dragGroup = new DraggableGroup();
      dropGroup= new DropzoneGroup();

    load_data();
    
  }

}
