import 'package:browser_data/browsers.dart';

Future<void> main(List<String> args) async {
  var hi = await Chrome().fetchHistory();
  for (var e in hi) {
    print(e.toJson());
    print('=' * 20);
  }
}
