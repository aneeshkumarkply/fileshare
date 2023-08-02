import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:is_tv/is_tv.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controllers/ad_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fileshare/methods/handle_share.dart';
import '../../controllers/controllers.dart';
import '../../services/fileshare_sender.dart';
import '../apps_list.dart';

class WidescreenHome extends StatefulWidget {
  const WidescreenHome({Key? key}) : super(key: key);

  @override
  State<WidescreenHome> createState() => _WidescreenHomeState();
}

class _WidescreenHomeState extends State<WidescreenHome> {
  bool _isTV = false;
  bool isLoading = false;
  Box box = Hive.box('appData');
  // TODO: Add _bannerAd
  late BannerAd _bannerAd;
  late  NativeAd _ad;
  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;

  Future<void> initPlatformState() async {
    bool isTV = await IsTV().check().catchError((_) => false) ?? false;

    setState(() {
      _isTV = isTV;
    });
  }

  @override
  void initState(){
    super.initState();

    initPlatformState();
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
              print('Ad load failed (code=${error.code} message=${error
                  .message})');
            },
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
    if (_isTV) {
      setState(() {
        _isBannerAdReady = false;
      });
      print("isAndroidTVyes");
      print(_isTV);
      print(_isBannerAdReady);
    }
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return
            Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
             /*     Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [ */
                      if (_isBannerAdReady)...{
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                          Align(
                          alignment: Alignment.topCenter,

                          child: Container(
                            // width: _bannerAd.size.width.toDouble(),
                            // height: _bannerAd.size.height.toDouble(),
                            // child: AdWidget(ad: _bannerAd),
                            height: size.height / 5,
                            width: size.width / 2,
                            child: AdWidget(ad: _ad),
                          ),)
                        ]),}
                      else ...{
                        Container(
                          height: size.height / 5,
                        ),
                      },

                if (!isLoading) ...{
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                  Card(
                    color: mode.isDark
                        ? const Color.fromARGB(255, 18, 23, 26)
                        : const Color.fromARGB(255, 241, 241, 241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          /*  if (_isTV) {
                            setState(() {
                              isLoading = true;
                            });
                            await FileShareSender.handleSharing();
                            setState(() {
                              isLoading = false;
                            });
                          }
                          else {*/
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      MaterialButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(15),
                                          ),
                                          minWidth:
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width /
                                              2,
                                          color: mode.isDark
                                              ? const Color.fromARGB(
                                              205, 117, 255, 122)
                                              : Colors.blue,
                                          onPressed: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            await FileShareSender
                                                .handleSharing();
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: const [
                                              Icon(
                                                Icons.file_open,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Files',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      MaterialButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(15),
                                          ),
                                          minWidth:
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width /
                                              2,
                                          color: mode.isDark
                                              ? const Color.fromARGB(
                                              205, 117, 255, 122)
                                              : Colors.blue,
                                          onPressed: () async {
                                            if (box.get('queryPackages')) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                      const AppsList()));
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Query installed packages'),
                                                    content: const Text(
                                                        'To get installed apps, you need to allow photon to query all installed packages. Would you like to continue ?'),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                        const Text('Go back'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          box.put(
                                                              'queryPackages',
                                                              true);

                                                          Navigator.of(context)
                                                              .popAndPushNamed(
                                                              '/apps');
                                                        },
                                                        child: const Text(
                                                            'Continue'),
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/android.svg',
                                                color: Colors.white,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Text(
                                                'Apps',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                    ],
                                  );
                                });
                         // }
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          await FileShareSender.handleSharing();
                          setState(() {
                            isLoading = false;
                          });
                        }
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
                  SizedBox(
                    width: size.width / 10,
                  ),
                  Card(
                    color: mode.isDark
                        ? const Color.fromARGB(255, 18, 23, 26)
                        : const Color.fromARGB(255, 241, 241, 241),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    child: InkWell(
                      onTap: () {
                        if (Platform.isAndroid || Platform.isIOS) {
                          if (_isTV) {
          Navigator.of(context).pushNamed('/receivepage');
          }
                          else{
          showModalBottomSheet(
          context: context,
          builder: (context) {
          return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const SizedBox(
          height: 20,
          ),
          MaterialButton(
          onPressed: () async {
          HandleShare(context: context)
              .onNormalScanTap();
          },
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          ),
          minWidth:
          MediaQuery.of(context).size.width / 2,
          color: mode.isDark
          ? const Color.fromARGB(
          205, 117, 255, 122)
              : Colors.blue,
          child: const Text(
          'Normal mode',
          style: TextStyle(
          fontWeight: FontWeight.bold),
          ),
          ),
          const SizedBox(
          height: 25,
          ),
          MaterialButton(
          onPressed: () {
          HandleShare(context: context)
              .onQrScanTap();
          },
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          ),
          minWidth:
          MediaQuery.of(context).size.width / 2,
          color: mode.isDark
          ? const Color.fromARGB(
          205, 117, 255, 122)
              : Colors.blue,
          child: const Text(
          'QR code mode',
          style: TextStyle(
          fontWeight: FontWeight.bold),
          ),
          ),
          const SizedBox(
          height: 50,
          ),
          ],
          );
          });
          }
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
                ])} else ...{
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
                      'Please wait, file(s) are being fetched',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                }
              ],
               // )]
          );
        });
  }
}
