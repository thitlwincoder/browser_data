import 'package:browser_data/browser_data.dart';
import 'package:browser_data/model.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

import 'src/extensions/textstyle_extension.dart';
import 'src/extensions/theme_extension.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    skipTaskbar: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Browser History Example',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var broswer = BrowserData();

  List<History> histories = [];

  Future<void> getHistory() async {
    histories = await broswer.getHistory();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        backgroundColor: Colors.white,
        title: Text('Browser History Example', style: context.body),
        automaticallyImplyLeading: false,
        actions: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Ionicons.logo_chrome, size: 18),
                  onPressed: () {
                    getHistory();
                  },
                ),
                IconButton(
                  icon: Icon(Ionicons.logo_firefox, size: 18),
                  onPressed: () {},
                )
              ],
            ),
          ],
        ),
      ),
      content: ListView.builder(
        itemCount: histories.length,
        itemBuilder: (context, index) {
          var data = histories[index];
          return ListTile(
            title: Row(
              children: [
                Text(
                  DateFormat('HH:mm a').format(data.lastVisitTime!),
                  style: context.caption.textColor(Colors.grey),
                ),
                SizedBox(width: 20),
                Text(
                  data.title,
                  style: context.body,
                ),
                SizedBox(width: 20),
                Text(
                  Uri.parse(data.url).host,
                  style: context.caption.textColor(Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
