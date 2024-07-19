import 'dart:io';

class AdHelper {
  static String get titlesBannerAdUnitId {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-5295511803582847/1795094403';
      return 'ca-app-pub-3940256099942544/6300978111';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get tipsSelectBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // サンプルID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // メモリストバナー広告のユニットID
  static String get memoListBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // サンプルID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get mapBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // サンプルID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // ネイティブ広告のユニットID
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110'; // サンプルID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
