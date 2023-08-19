import 'browsers.dart';
import 'model.dart';



class BrowserData {
  BrowserData() {
    // open.overrideForAll(() {
    //   return DynamicLibrary.open('../sqlite3.dll');
    // });
  }

  Future<List<History>> getHistory() {
    var browser = Chrome();
    return browser.fetchHistory();
  }

  void getBookmark() {}
}
