import 'dart:io';

class AdHelper {
  static String get titlesBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5295511803582847/1795094403';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get tipsSelectBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5295511803582847/3797896045';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // メモリストバナー広告のユニットID
  static String get memoListBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5295511803582847/6978577246';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get mapBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5295511803582847/8537386711';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // ネイティブ広告のユニットID
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5295511803582847/2384726119';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
