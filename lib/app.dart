import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:fileshare/views/drawer/about_page.dart';
import 'package:fileshare/views/drawer/settings.dart';
import 'package:fileshare/views/home/widescreen_home.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/constants.dart';
import 'controllers/intents.dart';
import 'views/drawer/history.dart';
import 'views/home/mobile_home.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform/platform.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_update/in_app_update.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  TextEditingController usernameController = TextEditingController();
  String? appVersion;
  AppUpdateInfo? _updateInfo;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Future<void> ImmediateUpdate() async {
    //if (kIsWeb) {
    if (const LocalPlatform().isAndroid) {
      InAppUpdate.checkForUpdate().then((info) {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          if (info.immediateUpdateAllowed) {
            InAppUpdate.performImmediateUpdate().then((value) {}).catchError((
                e) {
              showSnack(e.toString());
            });
          }
        }
      }).catchError((e) {
        showSnack(e.toString());
      });
      // }
    }
  }


  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }


  @override
  void initState() {
    main();
    super.initState();
    ImmediateUpdate();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }


  Box box = Hive.box('appData');
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return ValueListenableBuilder(
      key: _scaffoldKey,
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (_, AdaptiveThemeMode mode, child) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: mode.isDark
              ? const Color.fromARGB(255, 27, 32, 35)
              : Colors.white,
          appBar: AppBar(
            backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
            title: const Text(
              'FileShare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            flexibleSpace: mode.isLight
                ? Container(
                    decoration: appBarGradient,
                  )
                : null,
          ),
          drawer: Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.backspace): GoBackIntent()
            },
            child: Actions(
              actions: {
                GoBackIntent: CallbackAction<GoBackIntent>(onInvoke: (intent) {
                  if (scaffoldKey.currentState!.isDrawerOpen) {
                    scaffoldKey.currentState!.openEndDrawer();
                  }
                  return null;
                })
              },
              child: Drawer(
                child: Stack(
                  children: [
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            children: [
                              Image.asset(
                                box.get('avatarPath'),
                                width: 90,
                                height: 90,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  box.get('username'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Divider(
                            thickness: 2,
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            UniconsSolid.history,
                            color: mode.isDark ? null : Colors.black,
                          ),
                          title: const Text('History'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return const HistoryPage();
                                },
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.settings,
                            color: mode.isDark ? null : Colors.black,
                          ),
                          title: const Text("Settings"),
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const SettingsPage();
                            }));
                          },
                        ),
                        /* ListTile(
                          leading: SvgPicture.asset(
                            'assets/icons/licenses.svg',
                            color: mode.isLight ? Colors.black : Colors.white,
                          ),
                          onTap: () {
                            showLicensePage(
                                context: context,
                                applicationLegalese: 'GPL3 license',
                                applicationVersion: '$appVersion',
                                applicationIcon: Image.asset(
                                  'assets/images/splash.png',
                                  width: 60,
                                ));
                          },
                          title: const Text('Licenses'),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.privacy_tip_rounded,
                            color: mode.isDark ? null : Colors.black,
                          ),
                          onTap: () async {
                            launchUrl(
                                Uri.parse(
                                    "https://fileshare.netlify.app/privacy-policy-page"),
                                mode: LaunchMode.externalApplication);
                          },
                          title: const Text('Privacy policy'),
                        ),*/
                        ListTile(
                          title: const Text('More App'),
                          leading: Icon(UniconsLine.info_circle,
                              color: mode.isDark ? null : Colors.black),
                          onTap: () async {
                            if (const LocalPlatform().isAndroid) {
                              final devID = 'Aneesh Kumar S';
                              final market = 'market://dev?id=$devID';
                              final url =
                                  'https://play.google.com/store/apps/developer?id=$devID';
                              if (await canLaunch(market)) {
                                await launch(market);
                              } else if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }
                            ;
                          },
                        ),
                        ListTile(
                          title: const Text('Share App'),
                          leading: Icon(UniconsLine.info_circle,
                              color: mode.isDark ? null : Colors.black),
                          onTap: () {if (const LocalPlatform().isAndroid) {
        Share.share(
        "https://play.google.com/store/apps/details?id=com.tripleafoodies.fileshare");
        };}
                        ),
                        ListTile(
                          title: const Text('Rate App'),
                          leading: Icon(UniconsLine.info_circle,
                              color: mode.isDark ? null : Colors.black),
                          onTap: () async {
                            if (const LocalPlatform().isAndroid) {
                              final appID = 'com.tripleafoodies.fileshare';
                              final market = 'market://details?id=$appID';
                              final url = 'https://play.google.com/store/apps/details?id=$appID';
                              if (await canLaunchUrl(Uri.parse(market))) {
                                await launchUrl(Uri.parse(market));
                              } else if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              } else {
                                throw 'Could not launch $url';
                              }
                              ;
                            }
                            ;
                          },
                        ),
                        ListTile(
                          title: const Text('About'),
                          leading: Icon(UniconsLine.info_circle,
                              color: mode.isDark ? null : Colors.black),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return const AboutPage();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 18,
                      right: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/icon.png',
                                width: 30, height: 30),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'FileShare v $appVersion',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          body: Center(
            child:
                size.width > 720 ? const WidescreenHome() : const MobileHome(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor:
                mode.isDark ? Colors.blueGrey.shade900 : Colors.white,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Help"),
                      content: const Text(
                        """1. Before sharing files make sure that you are connected to wifi or your mobile-hotspot is turned on.\n\n2. While receiving make sure you are connected to the same wifi or hotspot as that of sender.""",
                        textAlign: TextAlign.justify,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    );
                  });
            },
            icon: const Text("Help"),
            label: const Icon(Icons.help),
          ),
        );
      },
    );
  }
}
