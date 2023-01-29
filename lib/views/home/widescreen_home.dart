import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fileshare/services/fileshare_receiver.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controllers/ad_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:fileshare/methods/handle_share.dart';
import '../../services/fileshare_sender.dart';

class WidescreenHome extends StatefulWidget {
  const WidescreenHome({Key? key}) : super(key: key);

  @override
  State<WidescreenHome> createState() => _WidescreenHomeState();
}

class _WidescreenHomeState extends State<WidescreenHome> {
  bool isLoading = false;

  // TODO: Add _bannerAd
  late BannerAd _bannerAd;

  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;
  @override
  void initState() {
    super.initState();
    //_showBannerAd();
    // myBanner.load();
    if (Platform.isAndroid || Platform.isIOS) {
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
    }
  }

  @override
  void dispose() {
    super.dispose();
    // TODO: Dispose a BannerAd object
    if (Platform.isAndroid || Platform.isIOS) {
      _bannerAd.dispose();
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                  if (!isLoading) ...{
                    Card(
                      color: mode.isDark
                          ? const Color.fromARGB(255, 18, 23, 26)
                          : const Color.fromARGB(255, 241, 241, 241),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/lottie/rocket-send.json',
                              width: size.width / 4,
                              height: size.height / 4,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Share',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (_isBannerAdReady) ...{
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: _bannerAd.size.width.toDouble(),
                          height: _bannerAd.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd),
                        ),
                      ),}
                    else ...{
                    SizedBox(
                      width: size.width / 10,
                    ),},
                    Card(
                      color: mode.isDark
                          ? const Color.fromARGB(255, 18, 23, 26)
                          : const Color.fromARGB(255, 241, 241, 241),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                      child: InkWell(
                        onTap: () {
                          if (Platform.isAndroid || Platform.isIOS) {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Center(
                                    child: Container(
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pushNamed('/receivepage');
                                              },
                                              child: const Text('Normal mode'),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                // Navigator.of(context).push(
                                                //     MaterialPageRoute(
                                                //         builder: (context) {
                                                //   return const QrReceivePage();
                                                // }));
                                              },
                                              child: const Text('QR Code mode'),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            Navigator.of(context).pushNamed('/receivepage');
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset('assets/lottie/receive-file.json',
                                width: size.width / 4, height: size.height / 4),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Receive',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  } else
                    ...{
                      Center(
                        child: SizedBox(
                          width: size.width / 4,
                          height: size.height / 4,
                          child: Lottie.asset('assets/lottie/setting_up.json',
                              width: 40, height: 40),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Please wait !',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    }

                ],

          );
        });
  }
}
