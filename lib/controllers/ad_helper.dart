import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3829581963890407/4930038330';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      return '';
     // throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/1033173712";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

//Test
  static String get nativeAdUnitId1 {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/2247696110";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

//Correct
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3829581963890407/2204663109";
    } else if (Platform.isIOS) {
      return "";
    } else {
     // throw new UnsupportedError("Unsupported platform");
      return '';
    }
  }

  static String get nativeAdUnitId2 {
    if (Platform.isAndroid) {
      return "ca-app-pub-3829581963890407/5069304056";
    } else if (Platform.isIOS) {
      return "";
    } else {
      // throw new UnsupportedError("Unsupported platform");
      return '';
    }
  }

}
