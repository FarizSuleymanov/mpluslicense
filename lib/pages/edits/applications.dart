import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../model/userparams.dart';
import '../../util/api.dart';
import '../../util/returnmessages.dart';
import '../../widgets/widgets.dart';

class Applications extends StatefulWidget {
  const Applications(this.userParams, this.dataGridRow,
      {this.editMethod = 0, super.key});
  final UserParams userParams;
  final DataGridRow dataGridRow;
  final int editMethod;
  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  bool isLoading = true, isNewCard = true;

  String nullName = '[Boş]',
      appGuid = '00000000-0000-0000-0000-000000000000',
      webControllerName = 'Applications';
  TextEditingController txtName = TextEditingController();
  String? nullGuid = '00000000-0000-0000-0000-000000000000';

  Future<void> fillFields() async {
    List<DataGridCell<dynamic>> cells = widget.dataGridRow.getCells();
    if (cells.isNotEmpty) {
      isNewCard = widget.editMethod == 1 ? true : false;
      cells.map((e) {
        switch (e.columnName) {
          case 'appGuid':
            if (widget.editMethod == 0) {
              appGuid = e.value;
            }
            break;
          case 'appName':
            txtName.text = e.value;
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
    }

    if (msg != "") {
      ReturnMessages().showSnackBar(context, msg, 0);
      return;
    }

    Map bodydata = {"appGuid": appGuid, "appName": txtName.text};

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
      String err = await response.stream.bytesToString();
      if (mounted) {
        ReturnMessages().showSnackBar(context, err, 0);
      }
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
          title: const Text('Proqramlar'),
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
