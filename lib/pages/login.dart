import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../model/userparams.dart';
import '../theme/styles.dart';
import '../util/api.dart';
import '../util/returnmessages.dart';
import '../util/utils.dart';
import '../widgets/widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController txtUsername = TextEditingController(),
      txtPassword = TextEditingController();
  bool isLoading = true;
  String version = '';

  Future<void> checkSession() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;

    UserParams userParams = UserParams(
        userToken: '',
        userUID: '',
        userFullName: '',
        userRoll: 0,
        userCompanyName: '',
        serverName: '');
    try {
      userParams = UserParams.fromJson(await SessionManager().get("M+License"));
    } catch (e) {
      e.toString();
    }
    if (userParams.userToken.isNotEmpty) {
      bool isTokenExpired = JwtDecoder.isExpired(userParams.userToken);
      if (isTokenExpired) {
        await SessionManager().destroy();
      } else {
        if (mounted) Navigator.pushNamed(context, '/main');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> checkLoginAndOpenMainPage(String mail, String password) async {
    String serverURL = await getServerURLForWeb();
    String mainURl = '${serverURL}Tokens/GetTokenByFirms';
    String result = "";
    var uuid = const Uuid();
    String uuid_ = uuid.v6().replaceAll('-', '');

    var passBytes = utf8.encode(password);
    var passSha1 = sha1.convert(passBytes);
    String parametr = '${mail}_|_$passSha1';

    parametr = Utils().encryptData(parametr, uuid_);

    Map body = {"param": parametr, "processId": uuid_};
    http.StreamedResponse response =
        await API().getAuthorization_(mainURl, body);
    if (!context.mounted) return;
    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();

      String token = Utils().decryptData(responseData, uuid_);
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      UserParams userParams = UserParams(
          userToken: token,
          userUID: decodedToken["UserGuid"],
          userFullName: decodedToken["UserFullName"],
          userRoll: int.parse(decodedToken["UserRoll"]),
          userCompanyName: decodedToken['CompanyName'],
          serverName: serverURL);

      result = "Uğurlu giriş!";
      await SessionManager().set("M+License", userParams);
      if (!mounted) return;

      Navigator.pushNamed(context, '/main');
    } else if (response.statusCode == 400) {
      txtPassword.clear();
      result = "İstifadəçi və ya şifrə yanlışdır!";
    } else if (response.statusCode == 409) {
      result = await response.stream.bytesToString();
    } else {
      result = "Xəta baş verdi!";
    }
    if (mounted) {
      ReturnMessages()
          .showSnackBar(context, result, response.statusCode == 200 ? 1 : 0);
    }
  }

  Future<String> getServerURLForWeb() async {
    String serverURL = '';
    final jsonString =
        await DefaultAssetBundle.of(context).loadString('settings/config.json');
    final dynamic jsonMap = jsonDecode(jsonString);
    serverURL = jsonMap['server'] + '/api/';
    return serverURL;
  }

  void login() async {
    checkLoginAndOpenMainPage(txtUsername.text, txtPassword.text);
  }

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/login.png'), fit: BoxFit.cover),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Expanded(flex: 2, child: SizedBox()),
                      Container(
                        padding: const EdgeInsets.only(left: 35, top: 40),
                        child: Text(
                          'MPlus Lisenziya',
                          style: TextStyle(
                              color: Styles.defaultBlackColor,
                              fontSize: 43,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: Image.asset(
                          'assets/favicon.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Styles.scaffoldBackgroundColorMode
                                  .withAlpha(225),
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 25, right: 25),
                                child: Column(
                                  children: [
                                    Widgets().getTextFormField(
                                        txtUsername,
                                        (newValue) {},
                                        [],
                                        Icons.person,
                                        'İstifadəçi',
                                        'İstifadəçi adınızı daxil edin',
                                        false,
                                        false),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Widgets().getTextFormField(
                                        txtPassword,
                                        (newValue) => login(),
                                        [],
                                        Icons.password,
                                        'Şifrə',
                                        'Şifrənizi daxil edin',
                                        false,
                                        true),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Daxil ol',
                                          style: TextStyle(
                                              fontSize: 27,
                                              color: Styles.defaultBlackColor,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              Styles.defaultWidgetForeColor,
                                          child: IconButton(
                                              color: Colors.white,
                                              onPressed: () {
                                                login();
                                              },
                                              icon: const Icon(
                                                Icons.arrow_forward,
                                              )),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Expanded(flex: 3, child: SizedBox()),
                      Center(
                        child: Text(
                          version,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}
