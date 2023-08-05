import 'package:browser_history/browser_history.dart';

Future<void> main(List<String> arguments) async {
  var broswer = BrowserHistory();
  var histories = await broswer.getHistory();
  for (var e in histories) {
    print(e.toJson());
    print('-' * 10);
  }
}
