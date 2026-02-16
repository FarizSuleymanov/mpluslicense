import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../model/filters.dart';
import '../model/userparams.dart';
import 'api.dart';

class Utils {
  String encryptData(String clearData, String keyWord) {
    String tempKeyWord = List.generate(
      (clearData.length / keyWord.length).ceil() + 1,
      (index) => keyWord,
    ).join();
    String encryptedData = "";

    for (int i = 0; i < clearData.length; i++) {
      var dataCharToDecimal = clearData[i].codeUnitAt(0);
      var keyCharToDecimal = tempKeyWord[i].codeUnitAt(0);

      if (dataCharToDecimal + keyCharToDecimal < 127) {
        encryptedData +=
            String.fromCharCode(dataCharToDecimal + keyCharToDecimal);
      } else {
        encryptedData +=
            String.fromCharCode(dataCharToDecimal + keyCharToDecimal - 96);
      }
    }
    return base64.encode(utf8.encode(encryptedData));
  }

  String decryptData(String encryptedBase64Data, String keyWord) {
    String decodedData = utf8.decode(base64.decode(encryptedBase64Data));

    String tempKeyWord = List.generate(
      (decodedData.length / keyWord.length).ceil() + 1,
      (index) => keyWord,
    ).join();

    String decryptedData = "";

    for (int i = 0; i < decodedData.length; i++) {
      var dataCharToDecimal = decodedData[i].codeUnitAt(0);
      var keyCharToDecimal = tempKeyWord[i].codeUnitAt(0);

      if (dataCharToDecimal - keyCharToDecimal > 31) {
        decryptedData +=
            String.fromCharCode(dataCharToDecimal - keyCharToDecimal);
      } else {
        decryptedData +=
            String.fromCharCode(96 + dataCharToDecimal - keyCharToDecimal);
      }
    }
    return decryptedData;
  }

  List<GridColumn> getGridColumns(List list) {
    List<GridColumn> columns = [];
    list.map((e) {
      columns.add(GridColumn(
          columnName: e['key'],
          visible: e['visible'],
          width: e['width'],
          label: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                e['value'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ))));
    }).toList();
    return columns;
  }

  Future<void> setDatePickerValue(
      TextEditingController txtDate, BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('en', 'GB'),
    );
    if (pickedDate != null) {
      txtDate.text = formatDate(pickedDate, [dd, '.', mm, '.', yyyy]);
    }
  }

  Future<void> setTimePickerValue(
      TextEditingController txtTime, BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      String minute_ = '0${pickedTime.minute}';
      minute_ = minute_.substring(minute_.length - 2, minute_.length);

      String hour_ = '0${pickedTime.hour}';
      hour_ = hour_.substring(hour_.length - 2, hour_.length);

      txtTime.text = '$hour_:$minute_';
    }
  }

  String getDateFormatForInsert(String strDate) {
    return strDate.substring(6) +
        strDate.substring(3, 5) +
        strDate.substring(0, 2);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> tc = [];
    list.map((item) {
      tc.add(DropdownMenuItem(
          value: item['id'].toString(), child: Text(item['name'].toString())));
    }).toList();
    return tc;
  }

  List<DropdownMenuItem<String>> getStatusList() {
    List listTypes = [
      {'id': '0', 'name': 'Aktiv'},
      {'id': '1', 'name': 'Passiv'}
    ];
    return getDropDownMenuItems(listTypes);
  }

  Future<dynamic> getCardList(BuildContext context, UserParams userParams,
      String webControllerName, Map body) async {
    dynamic data;
    String url =
        "${userParams.serverName}$webControllerName/Get$webControllerName";
    http.StreamedResponse response =
        await API().request_(context, 'POST', url, body, userParams.userToken);
    if (response.statusCode == 200) {
      data = jsonDecode(await response.stream.bytesToString());
    }
    return data;
  }

  Future<List> getDropDownData(
      BuildContext context, UserParams userParams, String methodName) async {
    Pager pager = Pager(pageNumber: 1, pageSize: 1000000000);
    Filters filters = Filters(status: 1, pager: pager, filterConditions: []);
    Map body = filters.toJson();
    dynamic data =
        await Utils().getCardList(context, userParams, methodName, body);
    return data['objects'] as List;
  }
}
