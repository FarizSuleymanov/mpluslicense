import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../model/userparams.dart';
import '../../util/api.dart';
import '../../util/returnmessages.dart';
import '../../util/utils.dart';
import '../../widgets/widgets.dart';

class Users extends StatefulWidget {
  final UserParams userParams;
  final DataGridRow dataGridRow;
  final int editMethod;
  const Users(this.userParams, this.dataGridRow,
      {this.editMethod = 0, super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  bool isLoading = true, isNewCard = true;

  String nullName = '[Boş]',
      usrGuid = '00000000-0000-0000-0000-000000000000',
      webControllerName = 'Users';
  TextEditingController txtName = TextEditingController(),
      txtUrl = TextEditingController(),
      txtPort = TextEditingController();
  String? nullGuid = '00000000-0000-0000-0000-000000000000',
      selectedFirm,
      selectedApplication,
      selectedAppUser;
  List<DropdownMenuItem<String>> cmbFirms = [], cmbApplications = [];
  // cmbAppUsers = [];
  bool checkLoggedIn = false, checkDevice = true;

  // Future<void> getAppUserList() async {
  //   String msg = "";
  //   if (selectedApplication == null) {
  //     msg = 'Proqram seçilməyib!';
  //   } else if (selectedFirm == null) {
  //     msg = 'Firma seçilməyib!';
  //   } else if (txtPort.text == '') {
  //     msg = 'Port daxil edilməyib!';
  //   } else if (txtUrl.text == '') {
  //     msg = 'URL daxil edilməyib!';
  //   }
  //
  //   if (msg != "") {
  //     ReturnMessages().showSnackBar(context, msg, 0);
  //     return;
  //   }
  //
  //   // var headers = {
  //   //   'Content-Type': 'application/json',
  //   //   'Authorization': 'Bearer ' + widget.userParams.userToken
  //   // };
  //   // var request = http.Request('POST',
  //   //     Uri.parse('http://38.242.222.38:8590/api/Users/GetApplicationUsers'));
  //   // request.body = json.encode({
  //   //   "usrFirmGuid": "adba59ad-6513-11ef-a7be-22e04ca4310b",
  //   //   "usrAppGuid": "8493bf32-e933-11ef-bc24-207bd2a1873f",
  //   //   "usrURL": "http://38.242.222.38",
  //   //   "usrPort": "8690"
  //   // });
  //   // request.headers.addAll(headers);
  //   //
  //   // http.StreamedResponse response = await request.send();
  //   //
  //   // if (response.statusCode == 200) {
  //   //   print(await response.stream.bytesToString());
  //   // } else {
  //   //   print(response.reasonPhrase);
  //   // }
  //
  //   Map body = {
  //     "usrFirmGuid": selectedFirm,
  //     "usrAppGuid": selectedApplication,
  //     "usrURL": txtUrl.text,
  //     "usrPort": txtPort.text
  //   };
  //
  //   dynamic data;
  //   String url =
  //       "${widget.userParams.serverName}$webControllerName/GetApplicationUsers";
  //   http.StreamedResponse response = await API()
  //       .request_(context, 'POST', url, body, widget.userParams.userToken);
  //   if (response.statusCode == 200) {
  //     data = jsonDecode(await response.stream.bytesToString());
  //     cmbAppUsers = [];
  //     cmbAppUsers.add(DropdownMenuItem(
  //       value: nullGuid,
  //       child: const Text('[Boş]'),
  //     ));
  //     List listAppUsers = data as List;
  //     listAppUsers
  //         .sort((a, b) => a['userFullName'].compareTo(b['userFullName']));
  //     listAppUsers
  //         .map((e) => cmbAppUsers.add(DropdownMenuItem(
  //               value: e['userGuid'],
  //               child: Text(e['userFullName']),
  //             )))
  //         .toList();
  //
  //     setState(() {});
  //   } else {
  //     if (mounted) {
  //       String err = await response.stream.bytesToString();
  //       if (mounted) {
  //         ReturnMessages().showSnackBar(context, err, 0);
  //       }
  //     }
  //   }
  // }

  Future<void> fillFields() async {
    //cmbAppUsers.add(DropdownMenuItem(
    //   value: nullGuid,
    //   child: const Text('[Boş]'),
    // ));
    selectedAppUser = nullGuid;

    List listFirms =
        await Utils().getDropDownData(context, widget.userParams, 'Firms');
    listFirms
        .map((e) => cmbFirms.add(
            DropdownMenuItem(value: e['frmGuid'], child: Text(e['frmName']))))
        .toList();

    List listApplications = mounted
        ? await Utils()
            .getDropDownData(context, widget.userParams, 'Applications')
        : [];
    listApplications
        .map((e) => cmbApplications.add(
            DropdownMenuItem(value: e['appGuid'], child: Text(e['appName']))))
        .toList();

    List<DataGridCell<dynamic>> cells = widget.dataGridRow.getCells();
    if (cells.isNotEmpty) {
      isNewCard = widget.editMethod == 1 ? true : false;

      cells.map((e) {
        switch (e.columnName) {
          case 'usrGuid':
            if (widget.editMethod == 0) {
              usrGuid = e.value;
            }
            break;
          case 'usrName':
            txtName.text = e.value;
            break;
          case 'usrFirmGuid':
            selectedFirm = e.value;
            break;
          case 'usrAppGuid':
            selectedApplication = e.value;
            break;
          case 'usrLoggedIn':
            checkLoggedIn = e.value;
            break;
          case 'usrURL':
            txtUrl.text = e.value;
            break;
          case 'usrPort':
            txtPort.text = e.value;
            break;
          case 'usrCheckDevice':
            checkDevice = e.value;
            break;
          case 'usrAppUserGuid':
            selectedAppUser = e.value;
            break;
        }
      }).toList();
    }

    // await getAppUserList();

    // if (cells.isNotEmpty && widget.editMethod == 0) {
    //   cells.map((e) {
    //     switch (e.columnName) {
    //       case 'usrAppUserGuid':
    //         if (cmbAppUsers.where((c) => c.value == e.value).isNotEmpty) {
    //           selectedAppUser = e.value;
    //         }
    //         break;
    //     }
    //   }).toList();
    // }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> save_() async {
    String msg = "";
    if (selectedApplication == null) {
      msg = 'Proqram seçilməyib!';
    } else if (selectedFirm == null) {
      msg = 'Firma seçilməyib!';
    } else if (txtName.text == '') {
      msg = 'Ad daxil edilməyib!';
    }

    if (msg != "") {
      ReturnMessages().showSnackBar(context, msg, 0);
      return;
    }

    Map bodyData = {
      "usrGuid": usrGuid,
      "usrName": txtName.text,
      "usrFirmGuid": selectedFirm,
      "usrAppGuid": selectedApplication,
      "usrURL": txtUrl.text,
      "usrPort": txtPort.text,
      "usrAppUserGuid": selectedAppUser,
      "usrLoggedIn": checkLoggedIn,
      "usrCheckDevice": checkDevice
    };

    String url = "${widget.userParams.serverName}$webControllerName";
    http.StreamedResponse response = await API()
        .request_(context, 'POST', url, bodyData, widget.userParams.userToken);
    if (!context.mounted) return;
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(await response.stream.bytesToString());
      int resultCode = data['result'];
      if (mounted) {
        switch (resultCode) {
          case 0:
            ReturnMessages().showSnackBar(context, "Yadda saxlanıldı!", 1);
            Navigator.pop(context);
            break;
          case 1:
            ReturnMessages().showSnackBar(
                context, "Bu firma və bu proqram üçün bağlantı mövcuddur!", 0);
            break;
          case 2:
            ReturnMessages()
                .showSnackBar(context, "Bu ad başqa firmada mövcuddur!", 0);
            break;
          case 3:
            ReturnMessages().showSnackBar(
                context, "Bu proqram istifadəçisi artıq istifadə olunub!", 0);
            break;
          case 4:
            ReturnMessages().showSnackBar(
                context, "Bu proqram istifadəçisi artıq istifadə olunub!", 0);
            break;
          case 5:
            ReturnMessages()
                .showSnackBar(context, "Lisenziya sayını keçmisiniz!", 0);
            break;
        }
      }
    } else if (mounted) {
      ReturnMessages().showSnackBar(context, "Xəta yarandı!", 0);
    }
  }

  void cancel() {
    Navigator.pop(context);
  }

  List<SpeedDialChild> getSpeedDialChildren() {
    return Widgets().getCardEditOperationMenu(
        context, () => save_(), () => cancel(), isNewCard);
  }

  @override
  void initState() {
    super.initState();
    fillFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('İstifadəçilər'),
          automaticallyImplyLeading: false,
        ),
        floatingActionButton: Widgets().setSpeedDial(getSpeedDialChildren()),
        body: Center(
          child: !isLoading
              ? SizedBox(
                  height: double.infinity,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          decoration: BoxDecoration(
                              color: Colors.blueGrey.withAlpha(50),
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Widgets().getTextFormField(
                                    txtName,
                                    (v) => {},
                                    [
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                    Icons.drive_file_rename_outline,
                                    'Adı',
                                    'Adı daxil edin',
                                    false,
                                    false),
                                const SizedBox(
                                  height: 10,
                                ),
                                Widgets().getDropDownList(
                                    (v) => setState(() => selectedFirm = v!),
                                    selectedFirm,
                                    cmbFirms,
                                    'Firma',
                                    'Firmanı seçin',
                                    Icons.work),
                                const SizedBox(
                                  height: 10,
                                ),
                                Widgets().getDropDownList(
                                    (v) => setState(
                                        () => selectedApplication = v!),
                                    selectedApplication,
                                    cmbApplications,
                                    'Proqram',
                                    'Proqramı seçin',
                                    Icons.android),
                                const SizedBox(
                                  height: 10,
                                ),
                                Widgets().getCheckedBox(
                                    checkDevice,
                                    (v) => setState(() => checkDevice = v),
                                    'Qurğu yoxlanılsınmı?',
                                    Icons.devices),
                                !isNewCard
                                    ? const SizedBox(
                                        height: 10,
                                      )
                                    : Container(),
                                !isNewCard
                                    ? Widgets().getCheckedBox(
                                        checkLoggedIn,
                                        (v) =>
                                            setState(() => checkLoggedIn = v),
                                        "Giriş edilmiş",
                                        Icons.account_circle_sharp)
                                    : Container(),
                                // const SizedBox(
                                //   height: 10,
                                // ),
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       flex: 8,
                                //       child: Widgets().getTextFormField(
                                //           txtUrl,
                                //           (v) => {},
                                //           [
                                //             LengthLimitingTextInputFormatter(
                                //                 50),
                                //           ],
                                //           Icons.http,
                                //           'URL',
                                //           'URL-i daxil edin',
                                //           false,
                                //           false),
                                //     ),
                                //     const SizedBox(
                                //       width: 10,
                                //     ),
                                //     Expanded(
                                //       flex: 2,
                                //       child: Widgets().getTextFormField(
                                //           txtPort,
                                //           (v) => {},
                                //           [
                                //             FilteringTextInputFormatter
                                //                 .digitsOnly,
                                //           ],
                                //           Icons.http,
                                //           'Port',
                                //           'Portu daxil edin',
                                //           false,
                                //           false),
                                //     ),
                                //     // const SizedBox(
                                //     //   width: 10,
                                //     // ),
                                //     // Expanded(
                                //     //     child: IconButton(
                                //     //   onPressed: () => getAppUserList(),
                                //     //   icon: const Icon(Icons.refresh),
                                //     // ))
                                //   ],
                                // ),
                                // const SizedBox(
                                //   height: 10,
                                // ),
                                // Widgets().getDropDownList(
                                //     (v) => setState(() => selectedAppUser = v!),
                                //     selectedAppUser,
                                //     cmbAppUsers,
                                //     'Proqram istifadəçisi',
                                //     'Proqram istifadəçisini seçin',
                                //     Icons.account_circle_sharp),
                              ],
                            ),
                          ),
                        ),
                      )),
                )
              : Widgets().setLoading('Yenilənir...'),
        ));
  }
}
