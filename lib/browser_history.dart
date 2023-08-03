import 'package:browser_history/browsers.dart';
import 'package:browser_history/model.dart';

class BrowserHistory {
  Future<List<History>> getHistory() {
    var browser = Chrome();
    return browser.fetchHistory();
  }
}
