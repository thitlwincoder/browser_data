import 'package:browser_data/browsers.dart';

Future<void> main(List<String> args) async {
  // var history = await Chrome().fetchHistory();

  // for (var d in history) {
  //   print(d.toJson());
  //   print('-' * 10);
  // }

  var b = await Chrome().fetchBookmarks();

  for (var d in b!.bookmarkBar.children!) {
    print(d.toJson());
    print('=' * 10);
  }
}
