library main;
import 'dart:html';

void main() {
  query('#tmpl').model = 5;


  query("#add_url").query("#add").onClick.listen ( (e) {
    var url=( query("#add_url").query("#url") as InputElement).value;
    print ("add url");
    HttpRequest.getString("""/add?url=${url}""");
  });
}