import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mpluslicense/model/userparams.dart';
import 'package:uuid/uuid.dart';
import '../../theme/styles.dart';
import '../../util/api.dart';
import '../../util/returnmessages.dart';
import '../../util/utils.dart';
import '../../widgets/widgets.dart';

class ChangePassword extends StatefulWidget {
  final UserParams userParams;
  const ChangePassword(this.userParams, {super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController txtOldPassword = TextEditingController();
  final TextEditingController txtNewPassword = TextEditingController();
  final TextEditingController txtNewControlPassword = TextEditingController();

  void checkPassword() {
    String message = '';
    if (txtOldPassword.text == '') {
      message = 'Köhnə şifrə daxil etməlisiniz!';
    } else if (txtNewPassword.text == '') {
      message = 'Yeni şifrə daxil etməlisiz!';
    } else if (txtNewControlPassword.text == '') {
      message = 'Yeni şifrə(təkrar) daxil etməlisiz!';
    } else if (txtNewPassword.text != txtNewControlPassword.text) {
      message = 'Yeni şifrə və təkrarı bir-birilə uyğun deyil!';
    }
    if (message != '') {
      ReturnMessages().showSnackBar(context, message, 0);
    } else {
      changePassword(
          widget.userParams.userUID, txtOldPassword.text, txtNewPassword.text);
    }
  }

  String getPasswordSha1(String password) {
    var passBytes = utf8.encode(password);
    var passSha1 = sha1.convert(passBytes);
    return passSha1.toString();
  }

  Future<void> changePassword(
      String userId, String userOldPassword, String userNewPassword) async {
    var uuid = const Uuid();
    String uuid_ = uuid.v6().replaceAll('-', '');
    String parametr = Utils().encryptData(
        '${getPasswordSha1(userOldPassword)}_|_${getPasswordSha1(userNewPassword)}',
        uuid_);

    Map body_ = {"param": parametr, "processId": uuid_};
    String url_ = "${widget.userParams.serverName}Users/ChangeFirmPassword";
    http.StreamedResponse response = await API()
        .request_(context, 'POST', url_, body_, widget.userParams.userToken);
    if (response.statusCode == 200) {
      if (mounted) {
        ReturnMessages().showSnackBar(context, 'Şifrə dəyişdirildi!', 1);
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Şifrə dəyişdirilməsi")),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(75),
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Widgets().getTextFormField(
                            txtOldPassword,
                            (v) {},
                            [LengthLimitingTextInputFormatter(25)],
                            Icons.person,
                            "Könhə şifrə",
                            '*********',
                            false,
                            true),
                        const SizedBox(
                          height: 10,
                        ),
                        Widgets().getTextFormField(
                            txtNewPassword,
                            (v) {},
                            [LengthLimitingTextInputFormatter(25)],
                            Icons.person,
                            "Yeni şifrə",
                            '*********',
                            false,
                            true),
                        const SizedBox(
                          height: 10,
                        ),
                        Widgets().getTextFormField(
                            txtNewControlPassword,
                            (v) {},
                            [LengthLimitingTextInputFormatter(25)],
                            Icons.person,
                            "Yeni şifrə(təkrar)",
                            '*********',
                            false,
                            true),
                        const SizedBox(
                          height: 10,
                        ),
                        Widgets().getElevatedButton('Dəyişdir', () {
                          setState(() {
                            checkPassword();
                          });
                        }, Styles.defaultWidgetForeColor)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
