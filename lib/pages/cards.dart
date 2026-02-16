import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../../../model/userparams.dart';
import '../../../../../util/returnmessages.dart';
import '../../../../../util/utils.dart';
import '../model/filters.dart';
import '../util/api.dart';
import '../util/cardlistdatasource.dart';
import '../util/excel.dart';
import '../widgets/widgets.dart';
import 'edits/applications.dart';
import 'edits/connections.dart';
import 'edits/firms.dart';
import 'edits/users.dart';

// ignore_for_file: must_be_immutable
class Cards extends StatefulWidget {
  Cards(this.userParams, this.pageName, this.reloaded, {super.key});

  final UserParams userParams;
  final String pageName;
  bool reloaded;

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  bool reloaded = true, isLoading = true, reloaded_ = true;

  List<DropdownMenuItem<String>> dropDownMenuItemsStatus = [];
  var selectedStatusID = '0';
  String webControllerName = '',
      webParameterName = '',
      selectedFirmGuid = 'all';
  List list = [];
  int pageCount = 1, rowsPerPage = 20, pageSelected = 1;
  List gridColumns = [];
  TextEditingController searchController = TextEditingController();
  List<DropdownMenuItem<String>> firms = [];

  late CardListDataSource cardListDataSource;

  Future<void> getData(dynamic selectedStatusID_, String selectedFirmGuid_,
      {String searchWord = ''}) async {
    setState(() {
      isLoading = true;
    });
    List<FilterConditions> listFilterForSend = [];
    if (selectedFirmGuid_ != 'all') {
      listFilterForSend.add(FilterConditions(
          isUsed: true,
          columnName: 'frm.frmFullName',
          condition: '===',
          valueX: selectedFirmGuid_,
          valueY: ''));
    }

    if (searchWord != '') {
      listFilterForSend.add(FilterConditions(
          isUsed: true,
          columnName: getSearchElementName(),
          condition: '%%%',
          valueX: searchWord,
          valueY: ''));
    }
    Pager pager = Pager(pageNumber: pageSelected, pageSize: rowsPerPage);
    Filters filters = Filters(
        status: selectedStatusID_ == '0' ? 1 : 0,
        pager: pager,
        filterConditions: listFilterForSend);
    Map body = filters.toJson();
    dynamic data = await Utils()
        .getCardList(context, widget.userParams, webControllerName, body);
    list = data['objects'] as List;
    int rowCount = data['count'] as int;
    pageCount = (rowCount / rowsPerPage).ceil();
    pageCount = pageCount == 0 ? 1 : pageCount;
    setState(() {
      isLoading = false;
      reloaded = false;
      selectedStatusID = selectedStatusID_;
      selectedFirmGuid = selectedFirmGuid_;
    });
  }

  List<SpeedDialChild> getSpeedDialChildren() {
    return [
      SpeedDialChild(
          child: const Icon(Icons.add),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: 'Əlavə et',
          onTap: () async {
            DataGridRow dataGridRow = const DataGridRow(cells: []);
            await Navigator.push(context, editPage(dataGridRow));
            if (!mounted) return;
            getData(selectedStatusID, selectedFirmGuid);
          }),
      SpeedDialChild(
          child: const Icon(Icons.table_chart),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          label: 'Excel-ə köçür',
          onTap: () {
            exportToExcel();
          }),
    ];
  }

  void _showContextMenu(
    BuildContext context,
    Offset globalPosition,
    DataGridRow row,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          onTap: () {
            rowEdit(row);
          },
          child: Center(child: Text('Dəyişdir')),
        ),
        PopupMenuItem<String>(
          onTap: () {
            rowCopy(row);
          },
          child: Center(child: Text('Köçür')),
        ),
        PopupMenuItem<String>(
          onTap: () {
            rowDelete(row);
          },
          child: Center(child: Text('Sil')),
        ),
        PopupMenuItem<String>(
          onTap: () {
            rowChangeStatus(row);
          },
          child: Center(
              child: Text(selectedStatusID == '0' ? "Passiv et" : "Aktiv et")),
        ),
      ],
      elevation: 8.0,
    );
  }

  String getGuidFromRow(DataGridRow row) {
    List<DataGridCell<dynamic>> cells = row.getCells();
    String rowGuid = "";
    if (cells.isNotEmpty) {
      List<DataGridCell<dynamic>> listGuid = cells
          .where((element) => element.columnName == webParameterName)
          .toList();
      rowGuid = listGuid[0].value;
    }
    return rowGuid;
  }

  Future<void> rowEdit(DataGridRow row) async {
    if (selectedStatusID == '0') {
      await Navigator.push(context, editPage(row));
      if (!mounted) return;
      getData(selectedStatusID, selectedFirmGuid);
    } else {
      ReturnMessages()
          .showSnackBar(context, 'Əvvəlcə kartı aktiv etməlisiniz!', 0);
    }
  }

  Future<void> rowCopy(DataGridRow row) async {
    if (selectedStatusID == '0') {
      await Navigator.push(context, editPage(row, editMethod: 1));
      if (!mounted) return;
      getData(selectedStatusID, selectedFirmGuid);
    } else {
      ReturnMessages()
          .showSnackBar(context, 'Əvvəlcə kartı aktiv etməlisiniz!', 0);
    }
  }

  Future<void> rowDelete(DataGridRow row) async {
    if (selectedStatusID == '1') {
      String rowGuid = getGuidFromRow(row);
      if (rowGuid != "") {
        Map bodydata = {
          webParameterName: rowGuid,
          'status': selectedStatusID == '0' ? 1 : 0
        };
        await deleteCard(widget.userParams, webControllerName, bodydata, false);
      }
      getData(selectedStatusID, selectedFirmGuid);
    } else {
      ReturnMessages()
          .showSnackBar(context, 'Əvvəlcə kartı passiv etməlisiniz!', 0);
    }
  }

  Future<void> deleteCard(UserParams userParams, String webControllerName,
      Map body, bool closePage) async {
    String url = "${userParams.serverName}$webControllerName";
    http.StreamedResponse response = await API()
        .request_(context, 'DELETE', url, body, userParams.userToken);
    if (!context.mounted) return;
    if (response.statusCode == 200) {
      if (mounted) {
        ReturnMessages().showSnackBar(context, "Kart silindi!", 1);
        if (closePage) {
          if (mounted) Navigator.pop(context);
        }
      }
    } else {
      if (mounted) ReturnMessages().showSnackBar(context, "Xəta yarandı!", 0);
    }
  }

  Future<void> rowChangeStatus(DataGridRow row) async {
    String rowGuid = getGuidFromRow(row);
    if (rowGuid != "") {
      Map bodydata = {
        webParameterName: rowGuid,
        'status': selectedStatusID == '0' ? 0 : 1
      };
      await changeCardStatus(widget.userParams, webControllerName, bodydata,
          selectedStatusID, false);
    }
    getData(selectedStatusID, selectedFirmGuid);
  }

  Future<void> changeCardStatus(UserParams userParams, String webControllerName,
      Map body, String selectedStatusID, bool closePage) async {
    try {
      String url = "${userParams.serverName}$webControllerName";
      http.StreamedResponse response =
          await API().request_(context, 'PUT', url, body, userParams.userToken);
      if (response.statusCode == 200) {
        String resultMessage = await response.stream.bytesToString();
        if (mounted) {
          if (resultMessage == '') {
            resultMessage =
                "Kart ${selectedStatusID == '0' ? 'passiv' : 'aktiv'} edildi!";
          }
          ReturnMessages().showSnackBar(context, resultMessage, 1);
          if (closePage) {
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) ReturnMessages().showSnackBar(context, "Xəta yarandı!", 0);
      }
    } catch (e) {
      if (mounted) ReturnMessages().showSnackBar(context, "Xəta:$e", 0);
    }
  }

  void exportToExcel() async {
    ReturnMessages()
        .showSnackBar(context, 'Excel-ə köçürmə əməliyyatı başladıldı!', 1);
    ExcelOperations()
        .exportListToExcelFile(webControllerName, gridColumns, list);
  }

  void onColumnDragging(
      int type, String columnName, int cIndexFrom, int cIndexTo) {
    if (type == 0) {
      gridColumns.map((e) {
        if (e["key"] == columnName) {
          e["visible"] = false;
        }
      }).toList();
    } else if (type == 1) {
      try {
        dynamic element = gridColumns.elementAt(cIndexFrom);
        gridColumns.removeAt(cIndexFrom);
        gridColumns.insert(cIndexTo, element);
      } catch (e) {
        // ignored.
      }
    }
    setState(() {});
  }

  MaterialPageRoute editPage(DataGridRow row, {int editMethod = 0}) {
    switch (webControllerName) {
      case 'Firms':
        return MaterialPageRoute(
            builder: (context) => Firms(
                  widget.userParams,
                  row,
                  editMethod: editMethod,
                ));
      case 'Applications':
        return MaterialPageRoute(
            builder: (context) => Applications(
                  widget.userParams,
                  row,
                  editMethod: editMethod,
                ));
      case 'Connections':
        return MaterialPageRoute(
            builder: (context) => Connections(
                  widget.userParams,
                  row,
                  editMethod: editMethod,
                ));
      case 'Users':
        return MaterialPageRoute(
            builder: (context) => Users(
                  widget.userParams,
                  row,
                  editMethod: editMethod,
                ));
      default:
        return MaterialPageRoute(builder: (context) => const SizedBox());
    }
  }

  String getSearchElementName() {
    switch (webControllerName) {
      case 'Firms':
        return 'frmFullName';
      case 'Applications':
        return 'appName';
      case 'Connections':
        return 'app.appName';
      case 'Users':
        return 'usrName';
      default:
        return '';
    }
  }

  String getWebParameterName() {
    switch (webControllerName) {
      case 'Firms':
        return 'frmGuid';
      case 'Applications':
        return 'appGuid';
      case 'Connections':
        return 'conGuid';
      case 'Users':
        return 'usrGuid';
      default:
        return '';
    }
  }

  void onPageChanged(int v) {
    setState(() {
      pageSelected = v;
      getData(selectedStatusID, selectedFirmGuid);
    });
  }

  Future<void> getColumns() async {
    // gridColumns = await Caches().getSavedGridColumns(
    //     context, widget.userParams, 'CardList', webControllerName);

    switch (webControllerName) {
      case 'Firms':
        gridColumns = [
          {"key": "frmGuid", "value": "GUID", "visible": true, 'width': 400},
          {"key": "frmName", "value": "Adı", "visible": true, 'width': 200},
          {
            "key": "frmFullName",
            "value": "Tam Adı",
            "visible": true,
            'width': 400
          },
          {
            "key": "frmRoll",
            "value": "frmRoll",
            "visible": false,
            'width': 100
          },
          {
            "key": "frmRollName",
            "value": "Rolu",
            "visible": true,
            'width': 100
          },
        ];
        break;
      case 'Applications':
        gridColumns = [
          {"key": "appGuid", "value": "GUID", "visible": true, 'width': 400},
          {"key": "appName", "value": "Adı", "visible": true, 'width': 200},
        ];
        break;
      case 'Connections':
        gridColumns = [
          {
            "key": "conGuid",
            "value": "conGuid",
            "visible": false,
            'width': 100
          },
          {
            "key": "conFirmGuid",
            "value": "conFirmGuid",
            "visible": false,
            'width': 100
          },
          {
            "key": "conFirmName",
            "value": "Firma",
            "visible": true,
            'width': 400
          },
          {
            "key": "conAppGuid",
            "value": "conAppGuid",
            "visible": false,
            'width': 100
          },
          {
            "key": "conAppName",
            "value": "Proqram",
            "visible": true,
            'width': 200
          },
          {
            "key": "conLicenseLimit",
            "value": "Lisenziya limiti",
            "visible": true,
            'width': 200
          },
        ];
        break;
      case 'Users':
        gridColumns = [
          {
            "key": "usrGuid",
            "value": "usrGuid",
            "visible": false,
            'width': 100
          },
          {
            "key": "usrName",
            "value": "İstifadəçi adı",
            "visible": true,
            'width': 250
          },
          {
            "key": "usrFirmGuid",
            "value": "usrFirmGuid",
            "visible": false,
            'width': 100
          },
          {
            "key": "usrFirmName",
            "value": "Firma",
            "visible": true,
            'width': 250
          },
          {
            "key": "usrAppGuid",
            "value": "usrAppGuid",
            "visible": false,
            'width': 100
          },
          {
            "key": "usrApplicationName",
            "value": "Proqram",
            "visible": true,
            'width': 200
          },
          {
            "key": "usrLastLoginDate",
            "value": "Sonuncu giriş",
            "visible": true,
            'width': 200
          },
          {
            "key": "usrLoggedIn",
            "value": "Aktiv sessiya",
            "visible": true,
            'width': 150
          },
          {
            "key": "usrAppUserGuid",
            "value": "usrAppUserGuid",
            "visible": false,
            'width': 100
          },
          {"key": "usrURL", "value": "Url", "visible": true, 'width': 200},
          {"key": "usrPort", "value": "Port", "visible": true, 'width': 100},
          {
            "key": "usrCheckDevice",
            "value": "Qurğu yoxlama",
            "visible": true,
            'width': 150
          },
        ];
        break;
      default:
        gridColumns = [{}];
        break;
    }
  }

  Future<void> load() async {
    if (widget.userParams.userRoll == 0) {
      List listFirms =
          await Utils().getDropDownData(context, widget.userParams, 'Firms');
      firms = [];
      firms.add(DropdownMenuItem(value: 'all', child: Text('Hamısı')));
      listFirms.map((e) {
        if (e['frmName'] != 'Admin') {
          firms.add(DropdownMenuItem(
              value: e['frmFullName'], child: Text(e['frmFullName'])));
        }
      }).toList();
    }

    webControllerName = widget.pageName;
    webParameterName = getWebParameterName();
    dropDownMenuItemsStatus = Utils().getStatusList();
    selectedStatusID = '0';
    selectedFirmGuid = 'all';
    await getColumns();
    await getData(selectedStatusID, selectedFirmGuid);
    searchController.clear();
  }

  void setStateWhenReload() {
    if (widget.reloaded) {
      pageSelected = 1;
      load();
      widget.reloaded = false;
    }
  }

  void onSearchSubmitted(String searchWord) {
    getData(selectedStatusID, selectedFirmGuid, searchWord: searchWord);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    setStateWhenReload();
    cardListDataSource = CardListDataSource(list, gridColumns);
    return Widgets().setCardList(
        getSpeedDialChildren(),
        isLoading,
        (v1) => getData(v1, selectedFirmGuid),
        selectedStatusID,
        webControllerName == 'Users' && widget.userParams.userRoll == 0
            ? true
            : false,
        (v2) => getData(selectedStatusID, v2),
        selectedFirmGuid,
        firms,
        pageCount,
        pageSelected,
        (v) => onPageChanged(v),
        cardListDataSource,
        gridColumns,
        (row) => rowEdit(row),
        (row, globalPosition) => _showContextMenu(context, globalPosition, row),
        searchController,
        (searchWord) => onSearchSubmitted(searchWord));
  }
}
