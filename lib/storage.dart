library storage;
import "dart:io";
import "dart:isolate";

class PersistantMap<K,V> {
  final String filename;
  List<K> _unsaved=new List<K>();
  final Map<K,V> _data=new Map<K,V>();
  RandomAccessFile f;
  SendPort save_isolate;
  
  V operator [](K key) {
    return _data[key];
  }
  
  void operator []=(K key, V value) {
    _data[key]=value;
    _unsaved.add(key);
    
  }
  void delete(K key) {
    _data.remove(key);
    _unsaved.add(key);
  }
  Map<K,V> get data => _data;
 
  int get length => _data.length;
  
  bool containsKey(Object key){
    return _data.containsKey(key);
  }

  void save() {
    _unsaved.forEach( (key) {
      if ( _data.containsKey(key)) {
        save_isolate.send( {"key": key, "value":_data[key]});
      } else {
        save_isolate.send( {"key": key, "value": ''});
      }
    });
    _unsaved.clear();
  }
  


  PersistantMap.fromFile(this.filename ) {
    var file=new File(this.filename );
    try {
  
      file.readAsLinesSync().forEach( (String l) {     
        try {
          var k_v=l.split(',');
          
          if (k_v[1]!= '') {
            print( "add ${k_v}");
            _data[k_v[0]]=k_v[1];
          } else {
            if ( _data.containsKey(k_v[0] )) {
              print( "remove ${k_v}");
              _data.remove(k_v[0]);
            }
          }
        } catch (e) {
           print (e);
        }
      });

     
    }
    catch (e){
      file.createSync();
      
    }
    
    
  }
  
}

String gen_key(var store) {
  return "/k"+ store.length.toString();
}
