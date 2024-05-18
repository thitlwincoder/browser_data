# browser_data

[![pub package](https://img.shields.io/pub/v/browser_data.svg?logo=dart&logoColor=00b9fc)](https://pub.dev/packages/browser_data)
[![Last Commits](https://img.shields.io/github/last-commit/thitlwincoder/browser_data?logo=git&logoColor=white)](https://github.com/thitlwincoder/browser_data/commits/main)
[![GitHub repo size](https://img.shields.io/github/repo-size/thitlwincoder/browser_data)](https://github.com/thitlwincoder/browser_data)
[![License](https://img.shields.io/github/license/thitlwincoder/browser_data?logo=open-source-initiative&logoColor=green)](https://github.com/thitlwincoder/browser_data/blob/main/LICENSE)
<br>
[![Uploaded By](https://img.shields.io/badge/uploaded%20by-thitlwincoder-blue)](https://github.com/thitlwincoder)

`browser_data` is a dart package to retrieve the browser's data.

## Features
- [x] History
- [x] Bookmarks
- [x] Passwords
- [ ] Downloads

## Support Browsers
- Chromium
- Chrome
- Firefox
- LibreWolf
- Safari
- Edge
- Opera
- OperaGX
- Brave
- Vivaldi
- Epic
- Avast
- Torch
- Orbitum
- CentBrowser
- Yandex

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  browser_data: latest
```

Next, we need to install this

```sh
# Dart
pub get

# Flutter
flutter packages get
```
## Usage

Before starting, you must download [sqlite3.dll](https://github.com/thitlwincoder/browser_data/blob/main/example/sqlite3.dll) for this package.

If you want to get the `default` browser from the device :

```dart
import 'package:browser_data/browser_data.dart';

var browser = defaultBrowser(sqlite3Path: './sqlite3.dll');
```
You can also use it with a specific browser.
```dart
var browser = Chrome(sqlite3Path: './sqlite3.dll');
```

To get `history` from a browser.
You can limit the history count.

```dart
var outputs = await browser.fetchHistory(limit: 10);
```

To get `bookmarks` from a browser.

```dart
var outputs = await browser.fetchBookmarks();
```
## Contribution
Feel free to file an [issue](https://github.com/thitlwincoder/browser_data/issues/new) if you find a problem or make pull requests.

All contributions are welcome :)

## Disclaimer
I just wanted to let you know that I am not responsible for any misuse. This package is only for educational purposes.
