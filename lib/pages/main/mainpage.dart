import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mpluslicense/pages/main/topappbar.dart';

import '../../model/filters.dart';
import '../../model/navigationitems.dart';
import '../../model/userparams.dart';
import '../../theme/styles.dart';
import '../../util/utils.dart';
import '../../widgets/navigationbutton.dart';
import '../../widgets/widgets.dart';
import '../cards.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int activeTab = 0;
  bool isLoading = true;
  UserParams userParams = UserParams(
      userToken: '',
      userUID: '',
      userFullName: '',
      userRoll: 0,
      userCompanyName: '',
      serverName: '');
  String licenseInfo = '';
  Widget pages() {
    switch (activeTab) {
      case 0:
        return Cards(userParams, 'Users', true);
      case 1:
        return Cards(userParams, 'Firms', true);
      case 2:
        return Cards(userParams, 'Applications', true);
      case 3:
        return Cards(userParams, 'Connections', true);

      default:
        return Container();
    }
  }

  Future<void> checkUserSession() async {
    try {
      userParams = UserParams.fromJson(await SessionManager().get("M+License"));
    } catch (e) {
      e.toString();
    }

    if (userParams.userToken.isEmpty) {
      if (mounted) Navigator.pushNamed(context, '/login');
    } else {
      bool isTokenExpired = JwtDecoder.isExpired(userParams.userToken);
      if (isTokenExpired) {
        await SessionManager().destroy();
        if (mounted) Navigator.pushNamed(context, '/login');
      }
    }

    if (userParams.userRoll == 1) {
      licenseInfo = await getConnectionList();
    }
    setState(() {
      isLoading = false;
    });
  }

  List<BottomNavigationBarItem> getBottomNavigationBarItems() {
    List<BottomNavigationBarItem> listBarItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'İstifadəçilər',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assured_workload),
        label: 'Firmalar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.android),
        label: 'Proqramlar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.share),
        label: 'Bağlantılar',
      ),
    ];

    return listBarItems;
  }

  @override
  void initState() {
    super.initState();
    checkUserSession();
  }

  bool isMobile() {
    return MediaQuery.of(context).size.width < 600;
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, bottom: 15),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: TopAppBar(userParams),
          ),
          Expanded(child: pages()),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 70),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MPlus Lisenziya',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(licenseInfo,
                      style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktop() {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 230,
            constraints: const BoxConstraints(minHeight: 800),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(125),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: Image.asset(
                        'assets/favicon.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  Column(
                      children: userParams.userRoll == 0
                          ? NavigationItems.values
                              .map(
                                (e) => NavigationButton(
                                  onPressed: () {
                                    setState(() {
                                      activeTab = e.index;
                                    });
                                  },
                                  icon: e.icon,
                                  isActive: e.index == activeTab,
                                  title: e.title,
                                  isVisible: true,
                                ),
                              )
                              .toList()
                          : NavigationItemsFirms.values
                              .map(
                                (e) => NavigationButton(
                                  onPressed: () {
                                    setState(() {
                                      activeTab = e.index;
                                    });
                                  },
                                  icon: e.icon,
                                  isActive: e.index == activeTab,
                                  title: e.title,
                                  isVisible: true,
                                ),
                              )
                              .toList()),
                ],
              ),
            ),
          ),
          Expanded(child: _body())
        ],
      ),
    );
  }

  Widget _mobile() {
    return Scaffold(
      body: _body(),
      bottomNavigationBar: userParams.userRoll == 0
          ? BottomNavigationBar(
              items: getBottomNavigationBarItems(),
              currentIndex: activeTab, // Highlight the currently selected tab
              selectedItemColor: Styles.defaultWidgetForeColor,
              unselectedItemColor: Styles.defaultWidgetForeColor.withAlpha(100),
              onTap: (index) {
                setState(() {
                  activeTab = index;
                });
              },
            )
          : null,
    );
  }

  Future<String> getConnectionList() async {
    List<FilterConditions> listFilterForSend = [
      FilterConditions(
          isUsed: true,
          columnName: 'frm.frmFullName',
          condition: '===',
          valueX: userParams.userCompanyName,
          valueY: '')
    ];
    Pager pager = Pager(pageNumber: 1, pageSize: 1);
    Filters filters =
        Filters(status: 1, pager: pager, filterConditions: listFilterForSend);
    Map body = filters.toJson();
    dynamic data =
        await Utils().getCardList(context, userParams, 'Connections', body);
    List list = data['objects'] as List;
    String licenceCountInfo = list
        .map((e) => '${e['conAppName']}: ${e['conLicenseLimit']}')
        .toList()
        .join(';');

    return licenceCountInfo;
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? isMobile()
            ? _mobile()
            : _desktop()
        : Center(
            child: Widgets().setLoading('Yenilənilir...'),
          );
  }
}
