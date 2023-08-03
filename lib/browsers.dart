import 'package:browser_history/generic.dart';

class Chrome extends ChromiumBasedBrowser {
  Chrome()
      : super(
          name: 'Chrome',
          profileSupport: true,
          windowsPath: r'AppData\Local\Google\Chrome\User Data',
          aliases: ["chromehtml", "google-chrome", "chromehtm"],
        );
}
