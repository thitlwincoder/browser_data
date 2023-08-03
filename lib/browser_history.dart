import 'package:browser_history/browsers.dart';

class BrowserHistory {
  getHistory() async {
    var browser = Chrome();
    var histories = await browser.fetchHistory();
    for (var e in histories) {
      print(e.toJson());
    }
  }
}
