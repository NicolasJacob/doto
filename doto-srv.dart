import "dart:io";
import "dart:async";
import "dart:convert";
import "dart:isolate";
import "lib/storage.dart";

import "package:stream/stream.dart";

const HOST = "0.0.0.0";
const PORT = 8000;
var json_encoder=new JsonEncoder();
const LOG_REQUESTS = true;

PersistantMap<String,String> store;

void addUrl(HttpConnect connect) {
  if (connect.request.uri.query=="") {
    connect.response.write("""<html><body>
        <form method="GET" action="/add">
        URL: <input type="text" name="url">
        <input type="submit" value="Add">
        </form>
    </body></html>""");
  } else {
    var url=connect.request.uri.queryParameters["url"];
    var k=gen_key(store);
    store[k]=url;
    connect.response.write("""<html><body>
        Added : ${k}=> ${url}
        <form method="GET" action="/add">
        URL: <input type="text" name="url">
        <input type="submit" value="Add">
        </form>
    </body></html>""");
  }
  connect.response.close().catchError(print);
}
  
void list(HttpConnect connect) {
  connect.response.write(json_encoder.convert(store.data));
  connect.response.close();
}
void delete(HttpConnect connect) {
  var k=connect.request.uri.queryParameters["key"];
  
  store.delete(k);
  connect.response.write("{}");
  connect.response.close();
}

void redirectKey(HttpConnect connect) {
  var key=connect.request.uri.path;
  if ( store.containsKey(key)) {
    var url=store[key];
    print("Found key $key. Redirect to $url");
    connect.response.redirect( Uri.parse(url));
    connect.response.close().catchError(print);
  } else {
    connect.response.write("""
<html>
  <body>
        '$key' not found
  </body>
</html>""");
    connect.response.close().catchError(print);
  }
}

void serverInfo(HttpConnect connect) {
  final info = {"name": "Rikulo Stream", "version": connect.server.version};
  connect.response
    ..headers.contentType = contentTypes["json"]
    ..write(json_encoder.stringify(info));
  connect.response.close();
}


  

void remote_save() {
  print ('Remote save started');
  var file=new File('test.dat' );
  var f=file.openSync(mode:FileMode.APPEND);
  port.receive( (m,replyTo) {
    var key=m['key'];
    var value=m['value'];
    var v='${key},${value}\n';
    print ('Saved $v');
    f.writeStringSync(v);
  });
}


void main() {
  store= new PersistantMap<String,String>.fromFile('test.dat');

  store.save_isolate=spawnFunction(remote_save);
  
  new Timer.periodic(
      new Duration( seconds:1 ),
      (t) => store.save());
  
  var smap={ 
    "/info": serverInfo,
    "/list": list,
    "/delete": delete,
    "/add": addUrl,
    "/k.*":  redirectKey
  };
  var s=new StreamServer(
      uriMapping: smap,
      homeDir:'.').start(address:HOST,port:PORT);

  print("Serving doto on http://${HOST}:${PORT}.");

}