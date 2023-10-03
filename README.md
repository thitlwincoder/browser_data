# browser_data

[![pub package](https://img.shields.io/pub/v/browser_data.svg?logo=dart&logoColor=00b9fc)](https://pub.dev/packages/browser_data)
[![Last Commits](https://img.shields.io/github/last-commit/thitlwincoder/browser_data?logo=git&logoColor=white)](https://github.com/thitlwincoder/browser_data/commits/main)
[![GitHub repo size](https://img.shields.io/github/repo-size/thitlwincoder/browser_data)](https://github.com/thitlwincoder/browser_data)
[![License](https://img.shields.io/github/license/thitlwincoder/browser_data?logo=open-source-initiative&logoColor=green)](https://github.com/thitlwincoder/browser_data/blob/main/LICENSE)
<br>
[![Uploaded By](https://img.shields.io/badge/uploaded%20by-thitlwincoder-blue)](https://github.com/thitlwincoder)

`browser_data` is a dart package to retrieve browser's data.

## Features
- [x] History
- [x] Bookmarks
- [ ] Downloads
- [ ] Passwords

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

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  browser_data: latest
```

Next we need to install this

```sh
# Dart
pub get

# Flutter
flutter packages get
```
## Usage

Before start you must need to download [sqlite3.dll](https://github.com/thitlwincoder/browser_data/blob/main/bin/sqlite3.dll) for use this package.

```dart
import 'package:browser_data/browser_data.dart';

var chrome = Chrome(sqlite3Path: './sqlite3.dll');
```

To get `history` from a specific browser:
You can limit history count.

```dart
var outputs = await chrome.fetchHistory(limit: 10);
```

To get `bookmarks` from a specific browser:

```dart
var outputs = await chrome.fetchBookmarks();
```
## Contribution
Feel free to file an [issue](https://github.com/thitlwincoder/browser_data/issues/new) if you find a problem or make pull requests.

All contributions are welcome :)