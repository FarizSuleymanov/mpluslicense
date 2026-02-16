import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:mpluslicense/model/userparams.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../util/api.dart';
import '../../util/returnmessages.dart';
import '../../widgets/widgets.dart';

class Firms extends StatefulWidget {
  final UserParams userParams;
  final DataGridRow dataGridRow;
  final int editMethod;
  const Firms(this.userParams, this.dataGridRow,
      {this.editMethod = 0, super.key});

  @override
  State<Firms> createState() => _FirmsState();
}

class _FirmsState extends State<Firms> {
  bool isLoading = true, isNewCard = true;

  String nullName = '[Boş]',
      frmGuid = '00000000-0000-0000-0000-000000000000',
      webControllerName = 'Firms';
  TextEditingController txtName = TextEditingController(),
      txtFullName = TextEditingController(),
      txtPassword = TextEditingController(),
      txtPasswordCheck = TextEditingController();

  List<DropdownMenuItem<String>> cmbFirmType = [];

  String? nullGuid = '00000000-0000-0000-0000-000000000000',
      selectedFirmType = '1';

  Future<void> fillFields() async {
    cmbFirmType.add(const DropdownMenuItem(value: '0', child: Text('Admin')));
    cmbFirmType.add(const DropdownMenuItem(value: '1', child: Text('Firma')));

    List<DataGridCell<dynamic>> cells = widget.dataGridRow.getCells();
    if (cells.isNotEmpty) {
      isNewCard = widget.editMethod == 1 ? true : false;
      cells.map((e) {
        switch (e.columnName) {
          case 'frmGuid':
            if (widget.editMethod == 0) {
              frmGuid = e.value;
            }
            break;
          case 'frmName':
            txtName.text = e.value;
            break;
          case 'frmFullName':
            txtFullName.text = e.value;
            break;
          case 'frmRoll':
            selectedFirmType = e.value.toString();
            break;
        }
      }).toList();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> save_() async {
    String msg = "";

    if (txtName.text == "") {
      msg = "Adı daxil edilməyib!";
    } else if (isNewCard && txtPassword.text == "") {
      msg = "Şifrə daxil edilməyib!";
    } else if (isNewCard && txtPasswordCheck.text == "") {
      msg = "Təkrar şifrə daxil edilməyib!";
    } else if (txtPassword.text != "" &&
        txtPassword.text != txtPasswordCheck.text) {
      msg = "Şifrələr uyğun deyil!";
    }

    if (msg != "") {
      ReturnMessages().showSnackBar(context, msg, 0);
      return;
    }
    var passBytes = utf8.encode(txtPassword.text);
    var passSha1 = sha1.convert(passBytes);

    Map bodydata = {
      "frmGuid": frmGuid,
      "frmName": txtName.text,
      "frmPassword": passSha1.toString(),
      "frmFullName": txtFullName.text,
      "frmRoll": int.parse(selectedFirmType.toString()),
    };

    String url = "${widget.userParams.serverName}$webControllerName";
    http.StreamedResponse response = await API()
        .request_(context, 'POST', url, bodydata, widget.userParams.userToken);
    if (!context.mounted) return;
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(await response.stream.bytesToString());
      int resultCode = data['result'];
      if (resultCode == 0 && mounted) {
        ReturnMessages().showSnackBar(context, "Yadda saxlanıldı!", 1);
        Navigator.pop(context);
      } else if (resultCode == 1 && mounted) {
        ReturnMessages()
            .showSnackBar(context, "Bu adla eyni olan kart mövcuddur!", 0);
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
          title: const Text('Firmalar'),
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
                                      LengthLimitingTextInputFormatter(20),
                                    ],
                                    Icons.drive_file_rename_outline,
                                    'Adı',
                                    'Adı daxil edin',
                                    false,
                                    false),
                                const SizedBox(
                                  height: 10,
                                ),
                                Widgets().getTextFormField(
                                    txtFullName,
                                    (v) => {},
                                    [
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                    Icons.drive_file_rename_outline,
                                    'Tam adı',
                                    'Tam adı daxil edin',
                                    false,
                                    false),
                                const SizedBox(
                                  height: 10,
                                ),
                                Widgets().getDropDownList((v) {
                                  setState(() {
                                    selectedFirmType = v!;
                                  });
                                }, selectedFirmType, cmbFirmType, 'Tipi',
                                    'Tipini seçin', Icons.category),
                                const SizedBox(
                                  height: 10,
                                ),
                                Widgets().getTextFormField(
                                    txtPassword,
                                    (v) => {},
                                    [
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                    Icons.password,
                                    'Şifrə',
                                    'Şifrəni daxil edin',
                                    false,
                                    true),
                                const SizedBox(
                                  height: 10,
                                ),
                                Widgets().getTextFormField(
                                    txtPasswordCheck,
                                    (v) => {},
                                    [
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                    Icons.password,
                                    'Təkrar şifrə',
                                    'Təkrar şifrəni daxil edin',
                                    false,
                                    true),
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
