import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fileshare/services/fileshare_receiver.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controllers/ad_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:fileshare/methods/handle_share.dart';
import '../../services/fileshare_sender.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  FileShareSender fileshareSeFileShareSender = FileShareSender();
  bool isLoading = false;

  // TODO: Add _bannerAd
  late BannerAd _bannerAd;
  late  NativeAd _ad;
  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;
  @override
  void initState() {
    super.initState();
    //_showBannerAd();
    // myBanner.load();
    if (Platform.isAndroid || Platform.isIOS) {

     // MobileAds.instance.updateRequestConfiguration(
         //RequestConfiguration(testDeviceIds: ['4E019D6BA455788B40B0B66DFA3F38E4']));
       //RequestConfiguration(testDeviceIds: ['B8893CF5156FE5AA9F87F038AE32C0EC']));
      // TODO: Initialize _bannerAd
      _bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
              // print('Ads to loaded');
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${err.message}');
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );

      _bannerAd.load();


      _ad = NativeAd(
        adUnitId: AdHelper.nativeAdUnitId,
        factoryId: 'listTile',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _ad = ad as NativeAd;
              _isBannerAdReady = true;
               print('Ads to loaded');
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            ad.dispose();
            _isBannerAdReady = false;
            print('Ad load failed (code=${error.code} message=${error.message})');       },
        ),
      );

      _ad.load();
    }
  }

  @override
  void dispose() {
    super.dispose();
    // TODO: Dispose a BannerAd object
    if (Platform.isAndroid || Platform.isIOS) {
      _bannerAd.dispose();
      _ad.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isBannerAdReady)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                   // width: _bannerAd.size.width.toDouble(),
                   // height: _bannerAd.size.height.toDouble(),
                   // child: AdWidget(ad: _bannerAd),
                    height: size.height / 6,
                    width: size.width / 1.1,
                    child: AdWidget(ad: _ad),
                  ),
                ),
              if (!isLoading) ...{
                Card(
                  color: mode.isDark
                      ? const Color.fromARGB(255, 18, 23, 26)
                      : const Color.fromARGB(255, 241, 241, 241),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await FileShareSender.handleSharing(context);
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/lottie/rocket-send.json',
                          width: size.width / 1.6,
                          height: size.height /5,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Share',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Card(
                  color: mode.isDark
                      ? const Color.fromARGB(255, 18, 23, 26)
                      : const Color.fromARGB(255, 241, 241, 241),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: InkWell(
                    onTap: () {
                      if (Platform.isAndroid || Platform.isIOS) {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Center(
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          HandleShare(context: context)
                                              .onNormalScanTap();
                                        },
                                        child: const Text('Normal mode'),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          HandleShare(context: context)
                                              .onQrScanTap();
                                        },
                                        child: const Text('QR Code mode'),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      } else {
                        Navigator.of(context).pushNamed('/receivepage');
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Lottie.asset(
                          'assets/lottie/receive-file.json',
                          width: size.width / 1.6,
                          height: size.height / 6,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Receive',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              } else ...{
                Center(
                  child: SizedBox(
                    width: size.width / 4,
                    height: size.height / 4,
                    child: Lottie.asset(
                      'assets/lottie/setting_up.json',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Please wait !',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              },
            ],
          );
        });
  }
}
