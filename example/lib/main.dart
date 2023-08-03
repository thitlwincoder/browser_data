import 'package:browser_history/browser_history.dart';
import 'package:browser_history/model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Browser History Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Browser History Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var broswer = BrowserHistory();

  List<History> histories = [];

  Future<void> getHistory() async {
    histories = await broswer.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: getHistory,
        child: ListView.builder(
          itemCount: histories.length,
          itemBuilder: (context, index) {
            var data = histories[index];
            return ListTile(
              title: Text(data.title),
              subtitle: Text(data.url),
            );
          },
        ),
      ),
    );
  }
}
