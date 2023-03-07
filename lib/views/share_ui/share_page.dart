import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controllers/ad_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:fileshare/components/constants.dart';
import 'package:fileshare/components/dialogs.dart';
import 'package:fileshare/controllers/controllers.dart';
import 'package:fileshare/models/sender_model.dart';
import 'package:fileshare/services/fileshare_sender.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../components/components.dart';

class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  SenderModel senderModel = FileShareSender.getServerInfo();
  FileShareSender fileshareSender = FileShareSender();
  late double width;
  late double height;
  bool willPop = false;
  var receiverDataInst = GetIt.I.get<ReceiverDataController>();

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
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      child: ValueListenableBuilder(
          valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
          builder: (_, AdaptiveThemeMode mode, __) {
            return Scaffold(
                backgroundColor: mode.isDark
                    ? const Color.fromARGB(255, 27, 32, 35)
                    : Colors.white,
                appBar: AppBar(
                  backgroundColor:
                      mode.isDark ? Colors.blueGrey.shade900 : null,
                  title: const Text('Share'),
                  leading: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        sharePageAlertDialog(context);
                      }),
                  flexibleSpace: mode.isLight
                      ? Container(
                          decoration: appBarGradient,
                        )
                      : null,
                ),
                body: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (width > 720) ...{
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                ),]),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                            //  Lottie.asset(
                            //    'assets/lottie/share.json',
                             //   width: 240,
                             // ),
                              SizedBox(
                                width: width / 8,
                              ),
                              SizedBox(
                                width: width > 720 ? 200 : 100,
                                height: width > 720 ? 200 : 100,
                                child: QrImage(
                                  size: 150,
                                  foregroundColor: Colors.black,
                                  data: FileShareSender.getFileShareLink,
                                  backgroundColor: Colors.white,
                                ),
                              )
                            ]
                          )
                        } else ...{
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                          ),]),
                        //  Lottie.asset(
                         //   'assets/lottie/share.json',
                        //  ),
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: QrImage(
                              size: 150,
                              foregroundColor: Colors.black,
                              data: FileShareSender.getFileShareLink,
                              backgroundColor: Colors.white,
                            ),
                          )
                        },
                        Text(
                          '${fileshareSender.hasMultipleFiles ? 'Your files are ready to be shared' : 'Your file is ready to be shared'}\nAsk receiver to tap on receive button',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width > 720 ? 18 : 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        //receiver data
                        Obx((() => GetIt.I
                                .get<ReceiverDataController>()
                                .receiverMap
                                .isEmpty
                            ? Card(
                                color: mode.isDark
                                    ? const Color.fromARGB(255, 29, 32, 34)
                                    : const Color.fromARGB(255, 241, 241, 241),
                                clipBehavior: Clip.antiAlias,
                                elevation: 8,
                                // color: Platform.isWindows ? Colors.grey.shade300 : null,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                child: SizedBox(
                                  height: width > 720 ? 200 : 128,
                                  width: width > 720 ? width / 2 : width / 1.25,
                                  child: Center(
                                    child: Wrap(
                                      direction: Axis.vertical,
                                      children: infoList(
                                          senderModel,
                                          width,
                                          height,
                                          true,
                                          mode.isDark ? "dark" : "bright"),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: width / 1.2,
                                child: Card(
                                  color: mode.isDark
                                      ? const Color.fromARGB(255, 45, 56, 63)
                                      : const Color.fromARGB(
                                          255, 241, 241, 241),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        receiverDataInst.receiverMap.length,
                                    itemBuilder: (context, item) {
                                      var keys = receiverDataInst
                                          .receiverMap.keys
                                          .toList();

                                      var data = receiverDataInst.receiverMap;

                                      return ListTile(
                                        title: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (item == 0) ...{
                                                const Center(
                                                  child: Text("Sharing status"),
                                                ),
                                              },
                                              const Divider(
                                                thickness: 2.4,
                                                indent: 20,
                                                endIndent: 20,
                                                color: Color.fromARGB(
                                                    255, 109, 228, 113),
                                              ),
                                              Center(
                                                child: Text(
                                                  "Receiver name : ${data[keys[item]]['hostName']}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              data[keys[item]]['isCompleted'] ==
                                                      'true'
                                                  ? const Center(
                                                      child: Text(
                                                        "All files sent",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )
                                                  : Center(
                                                      child: Text(
                                                          "Sending '${data[keys[item]]['currentFileName']}' (${data[keys[item]]['currentFileNumber']} out of ${data[keys[item]]['filesCount']} files)"),
                                                    )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ))),
                      ],
                    ),
                  ),
                ));
          }),
      onWillPop: () async {
        willPop = await sharePageWillPopDialog(context);
        GetIt.I.get<ReceiverDataController>().receiverMap.clear();
        return willPop;
      },
    );
  }
}
