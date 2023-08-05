import 'package:fluent_ui/fluent_ui.dart';

extension ThemeExtension on BuildContext {
  FluentThemeData get theme => FluentTheme.of(this);

  Typography get textTheme => theme.typography;

  TextStyle get display => textTheme.display!;

  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get title => textTheme.title!;

  TextStyle get subtitle => textTheme.subtitle!;

  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyStrong => textTheme.bodyStrong!;
  TextStyle get body => textTheme.body!;

  TextStyle get caption => textTheme.caption!;
}
