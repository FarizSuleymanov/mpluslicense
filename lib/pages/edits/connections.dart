import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../model/filters.dart';
import '../../model/userparams.dart';
import '../../util/api.dart';
import '../../util/returnmessages.dart';
import '../../util/utils.dart';
import '../../widgets/widgets.dart';

class Connections extends StatefulWidget {
  const Connections(this.userParams, this.dataGridRow,
      {this.editMethod = 0, super.key});
  final UserParams userParams;
  final DataGridRow dataGridRow;
  final int editMethod;
  @override
  State<Connections> createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> {
  bool isLoading = true, isNewCard = true;

  String nullName = '[Boş]',
      conGuid = '00000000-0000-0000-0000-000000000000',
      webControllerName = 'Connections';
  TextEditingController txtCount = TextEditingController();
  String? nullGuid = '00000000-0000-0000-0000-000000000000',
      selectedFirm,
      selectedApplication;
  List<DropdownMenuItem<String>> cmbFirms = [], cmbApplications = [];

  Future<List> getDropDownData(String methodName) async {
    Pager pager = Pager(pageNumber: 1, pageSize: 1000000000);
    Filters filters = Filters(status: 1, pager: pager, filterConditions: []);
    Map body = filters.toJson();
    dynamic data =
        await Utils().getCardList(context, widget.userParams, methodName, body);
    return data['objects'] as List;
  }

  Future<void> fillFields() async {
    List listFirms = await getDropDownData('Firms');
    listFirms
        .map((e) => cmbFirms.add(
            DropdownMenuItem(value: e['frmGuid'], child: Text(e['frmName']))))
        .toList();

    List listApplications = await getDropDownData('Applications');
    listApplications
        .map((e) => cmbApplications.add(
            DropdownMenuItem(value: e['appGuid'], child: Text(e['appName']))))
        .toList();

    List<DataGridCell<dynamic>> cells = widget.dataGridRow.getCells();
    if (cells.isNotEmpty) {
      isNewCard = widget.editMethod == 1 ? true : false;

      cells.map((e) {
        switch (e.columnName) {
          case 'conGuid':
            if (widget.editMethod == 0) {
              conGuid = e.value;
            }
            break;
          case 'conFirmGuid':
            selectedFirm = e.value;
            break;
          case 'conAppGuid':
            selectedApplication = e.value;
            break;
          case 'conLicenseLimit':
            txtCount.text = e.value.toString();
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
    if (selectedApplication == null) {
      msg = 'Proqram seçilməyib!';
    } else if (selectedFirm == null) {
      msg = 'Firma seçilməyib!';
    } else if (txtCount.text == '0' || txtCount.text == '') {
      msg = 'Limit 0 dan böyük olmalıdır';
    }

    if (msg != "") {
      ReturnMessages().showSnackBar(context, msg, 0);
      return;
    }

    Map bodydata = {
      "conGuid": conGuid,
      "conFirmGuid": selectedFirm,
      "conAppGuid": selectedApplication,
      "conLicenseLimit": int.parse(txtCount.text)
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
        ReturnMessages().showSnackBar(
            context, "Bu Firma və bu proqram üçün bağlantı mövcuddur!", 0);
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
          title: const Text('Bağlantılar'),
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
                                Widgets().getTextFormField(
                                    txtCount,
                                    (v) => {},
                                    [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    Icons.workspaces_sharp,
                                    'Lisenziya Limiti',
                                    'Limiti daxil edin',
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
