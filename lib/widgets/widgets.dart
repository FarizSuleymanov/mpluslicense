import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../dialog/alertdialog.dart';
import '../theme/styles.dart';
import '../util/cardlistdatasource.dart';
import '../util/utils.dart';

SampleItem? selectedMenu;

enum SampleItem {
  itemChange,
  itemDelete,
  itemChangeStatus,
  itemRegistrationData
}

class Widgets {
  Widget setSpeedDial(List<SpeedDialChild> children) {
    return SpeedDial(
      icon: Icons.edit,
      iconTheme: const IconThemeData(color: Colors.white),
      activeIcon: Icons.close,
      backgroundColor: Colors.redAccent,
      spacing: 3,
      mini: false,
      openCloseDial: ValueNotifier<bool>(false),
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      dialRoot: null,
      buttonSize: const Size(56.0, 56.0),
      label: null,
      activeLabel: null,
      childrenButtonSize: const Size(56.0, 56.0),
      visible: true,
      direction: SpeedDialDirection.up,
      switchLabelPosition: false,
      closeManually: false,
      renderOverlay: false,
      useRotationAnimation: true,
      elevation: 8.0,
      animationCurve: Curves.elasticInOut,
      isOpenOnStart: false,
      shape: const StadiumBorder(),
      children: children,
    );
  }

  Widget setLoading(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitWaveSpinner(
          size: 100,
          color: Colors.lightBlue,
          waveColor: Styles.defaultWidgetForeColor,
          trackColor: Styles.scaffoldBackgroundColorMode,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget getCardListOperationMenu(
      void Function() rowEditTap,
      void Function() rowDeleteTap,
      void Function() rowChangeStatusTap,
      String selectedStatusID) {
    return PopupMenuButton<SampleItem>(
      initialValue: selectedMenu,
      tooltip: 'Siyahı',
      icon: const Icon(
        Icons.more_horiz,
        size: 24,
      ),
      onSelected: (SampleItem item) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        PopupMenuItem<SampleItem>(
            value: SampleItem.itemChange,
            onTap: () {
              rowEditTap();
            },
            child: Center(
                child: Text('Dəyişdir',
                    style: TextStyle(
                      fontSize: 16,
                      color: Styles.defaultWidgetForeColor,
                    )))),
        PopupMenuItem<SampleItem>(
            value: SampleItem.itemDelete,
            onTap: () {
              rowDeleteTap();
            },
            child: Center(
                child: Text('Sil',
                    style: TextStyle(
                      fontSize: 16,
                      color: Styles.defaultWidgetForeColor,
                    )))),
        PopupMenuItem<SampleItem>(
            value: SampleItem.itemChangeStatus,
            onTap: () {
              rowChangeStatusTap();
            },
            child: Center(
                child: Text(selectedStatusID == '0' ? "Passiv et" : "Aktiv et",
                    style: TextStyle(
                      fontSize: 16,
                      color: Styles.defaultWidgetForeColor,
                    )))),
      ],
    );
  }

  Widget getCardListOperationMenuForSharings(void Function() rowEditTap,
      void Function() rowDeleteTap, void Function() rowRegistrationDataTap) {
    return PopupMenuButton<SampleItem>(
      initialValue: selectedMenu,
      tooltip: 'Siyahı',
      icon: const Icon(
        Icons.more_horiz,
        size: 24,
      ),
      onSelected: (SampleItem item) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        PopupMenuItem<SampleItem>(
            value: SampleItem.itemChange,
            onTap: () {
              rowEditTap();
            },
            child: Center(
                child: Text('Dəyişdir',
                    style: TextStyle(
                      fontSize: 16,
                      color: Styles.defaultWidgetForeColor,
                    )))),
        PopupMenuItem<SampleItem>(
            value: SampleItem.itemDelete,
            onTap: () {
              rowDeleteTap();
            },
            child: Center(
                child: Text('Sil',
                    style: TextStyle(
                      fontSize: 16,
                      color: Styles.defaultWidgetForeColor,
                    )))),
        PopupMenuItem<SampleItem>(
            value: SampleItem.itemRegistrationData,
            onTap: () {
              rowRegistrationDataTap();
            },
            child: Center(
                child: Text('Qeyd tarixçəsi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Styles.defaultWidgetForeColor,
                    )))),
      ],
    );
  }

  List<SpeedDialChild> getCardEditOperationMenu(BuildContext context,
      Future<void> Function() save, VoidCallback cancel, bool isNew) {
    return [
      SpeedDialChild(
        child: const Icon(Icons.save),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        label: 'Yadda saxla',
        onTap: () => ShowAlertDialog().showYesNoDialog(
            context, 'Xəbərdarlıq', 'Yadda saxlamaq istədiyinizə əminsinizmi?',
            () async {
          await save();
        }),
      ),
      SpeedDialChild(
        child: const Icon(Icons.cancel_presentation),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        label: 'Ləğv et',
        onTap: () => ShowAlertDialog().showYesNoDialog(
            context, 'Xəbərdarlıq', 'Ləğv etmək istədiyinizə əminsinizmi?',
            () async {
          cancel();
        }),
      ),
    ];
  }

  List<SpeedDialChild> getCardEditOperationMenuForSettings(
      BuildContext context, Future<bool> Function() save) {
    return [
      SpeedDialChild(
        child: const Icon(Icons.save),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        label: 'Yadda saxla',
        onTap: () => ShowAlertDialog().showYesNoDialog(
            context, 'Xəbərdarlıq', 'Yadda saxlamaq istədiyinizə əminsinizmi?',
            () async {
          await save();
        }),
      ),
    ];
  }

  List<SpeedDialChild> getCardEditOperationMenuForSharing(
      BuildContext context,
      Future<bool> Function() save,
      void Function() delete,
      void Function() cancel,
      bool isNew) {
    return [
      SpeedDialChild(
        child: const Icon(Icons.save),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        label: 'Yadda saxla',
        onTap: () => ShowAlertDialog().showYesNoDialog(
            context, 'Xəbərdarlıq', 'Yadda saxlamaq istədiyinizə əminsinizmi?',
            () async {
          bool result = await save();
          if (result && context.mounted) Navigator.pop(context);
        }),
      ),
      SpeedDialChild(
        child: const Icon(Icons.delete),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        visible: !isNew,
        label: 'Sil',
        onTap: () => ShowAlertDialog().showYesNoDialog(
            context, 'Xəbərdarlıq', 'Silmək istədiyinizə əminsinizmi?',
            () async {
          delete();
          Navigator.pop(context);
        }),
      ),
      SpeedDialChild(
        child: const Icon(Icons.cancel_presentation),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        label: 'Ləğv et',
        onTap: () => ShowAlertDialog().showYesNoDialog(
            context, 'Xəbərdarlıq', 'Ləğv etmək istədiyinizə əminsinizmi?',
            () async {
          cancel();
          Navigator.pop(context);
        }),
      ),
    ];
  }

  Widget getTextFormField(
      TextEditingController controller,
      void Function(String newValue) onFieldSubmitted,
      List<TextInputFormatter> inputFormatters,
      IconData icon,
      String labelText,
      String hintText,
      bool validate,
      bool obscureText) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        prefixIcon: Icon(
          icon,
          color: Styles.defaultWidgetForeColor,
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(200),
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: Styles.defaultWidgetForeColor),
        errorText: validate ? "Bu sahə boş ola bilməz!" : null,
      ),
      onFieldSubmitted: (value) {
        onFieldSubmitted(value);
      },
    );
  }

  Widget getDropDownList(
      void Function(String? newValue_) onChanged,
      String? selectedID,
      List<DropdownMenuItem<String>> items,
      String labelText,
      String hintText,
      IconData icon) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        prefixIcon: Icon(
          icon,
          color: Styles.defaultWidgetForeColor,
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(200),
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: Styles.defaultWidgetForeColor),
      ),
      items: items,
      onChanged: (String? newVal) {
        onChanged(newVal!);
      },
      initialValue: selectedID,
    );
  }

  Widget getTextFormFieldForDate(
    TextEditingController controller,
    void Function() onTap,
    String labelText,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: false,
      readOnly: true,
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        prefixIcon: Icon(
          Icons.calendar_month,
          color: Styles.defaultWidgetForeColor,
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(200),
        labelText: labelText,
        labelStyle: TextStyle(color: Styles.defaultWidgetForeColor),
      ),
      onTap: () {
        onTap();
      },
    );
  }

  Widget getIconButtonForNewCode(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: IconButton(
        onPressed: () {
          onPressed();
        },
        icon: const Icon(Icons.sync),
        tooltip: 'Yeni kod ver',
      ),
    );
  }

  Widget getElevatedButton(
      String label, VoidCallback onPressed, Color backgroundColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25)),
      onPressed: () {
        onPressed();
      },
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 20)),
    );
  }

  Widget getRichText(String header, String value, int colorType) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: <TextSpan>[
          TextSpan(
              text: '$header: ',
              style: TextStyle(
                  color: colorType == 0 ? Colors.black : Colors.white)),
          TextSpan(
              text: value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorType == 0 ? Colors.black : Colors.white)),
        ],
      ),
    );
  }

  Widget getCheckedBox(bool value, void Function(bool newValue) onChanged,
      String title, IconData icon) {
    return Container(
      height: 57,
      constraints: const BoxConstraints(maxWidth: 1200),
      decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              icon,
              color: Styles.defaultWidgetForeColor,
            ),
          ),
          Expanded(
              child: CheckboxListTile(
            value: value,
            onChanged: (bool? v) {
              onChanged(v!);
            },
            title: Text(
              title,
              style: TextStyle(color: Styles.defaultWidgetForeColor),
            ),
            controlAffinity: ListTileControlAffinity.trailing,
          )),
        ],
      ),
    );
  }

  Widget setCardList(
      List<SpeedDialChild> speedDialChildren,
      bool isLoading,
      void Function(dynamic newValue) onChangedForStatus,
      dynamic selectedStatusIDForStatus,
      bool isFirmShow,
      void Function(dynamic newValue) onChangedForFirmFilter,
      dynamic selectedStatusIDForFirmFilter,
      List<DropdownMenuItem> firms,
      int pageCount,
      int pageSelected,
      void Function(int newValue) onPageChanged,
      CardListDataSource dataGridSource,
      List gridColumns,
      void Function(DataGridRow row) editRow,
      void Function(DataGridRow row, Offset globalPosition) showContextMenu,
      TextEditingController searchController,
      void Function(String value) onSearchSubmitted) {
    List<GridColumn> columns = Utils().getGridColumns(gridColumns);
    return Stack(
      children: [
        !isLoading
            ? Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    setStatusAndSearchOnHead(
                        onChangedForStatus,
                        selectedStatusIDForStatus,
                        isFirmShow,
                        onChangedForFirmFilter,
                        selectedStatusIDForFirmFilter,
                        firms,
                        searchController,
                        onSearchSubmitted),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SfDataGrid(
                            source: dataGridSource,
                            columnWidthMode: ColumnWidthMode.fitByCellValue,
                            allowSorting: true,
                            headerRowHeight: 55,
                            showHorizontalScrollbar: true,
                            showColumnHeaderIconOnHover: true,
                            columns: columns,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            gridLinesVisibility: GridLinesVisibility.both,
                            onCellDoubleTap: (DataGridCellDoubleTapDetails d) {
                              int dataRowIndex = d.rowColumnIndex.rowIndex - 1;
                              if (dataRowIndex >= 0) {
                                final DataGridRow tappedRow =
                                    dataGridSource.effectiveRows[dataRowIndex];
                                editRow(tappedRow);
                              }
                            },
                            onCellSecondaryTap:
                                (DataGridCellTapDetails details) {
                              int dataRowIndex =
                                  details.rowColumnIndex.rowIndex - 1;
                              if (dataRowIndex >= 0) {
                                final DataGridRow tappedRow =
                                    dataGridSource.effectiveRows[dataRowIndex];
                                showContextMenu(
                                    tappedRow, details.globalPosition);
                              }
                            },
                            onCellLongPress: (DataGridCellLongPressDetails d) {
                              int dataRowIndex = d.rowColumnIndex.rowIndex - 1;
                              if (dataRowIndex >= 0) {
                                final DataGridRow tappedRow =
                                    dataGridSource.effectiveRows[dataRowIndex];
                                showContextMenu(tappedRow, d.globalPosition);
                              }
                            }),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: NumberPagination(
                        onPageChanged: (int pageNumber) {
                          onPageChanged(pageNumber);
                        },
                        totalPages: pageCount,
                        currentPage: pageSelected,
                      ),
                    )
                  ],
                ))
            : Center(
                child: setLoading('Yenilənir...'),
              ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: setSpeedDial(speedDialChildren),
        ),
      ],
    );
  }

  Widget setStatusAndSearchOnHead(
      void Function(dynamic newValue) onChangedForStatus,
      dynamic selectedStatusIDForStatus,
      bool isFirmShow,
      void Function(dynamic newValue) onChangedForFirmFilter,
      dynamic selectedStatusIDForFirmFilter,
      List<DropdownMenuItem> firms,
      TextEditingController? searchController,
      void Function(String value) onSearchSubmitted) {
    return Padding(
      padding: EdgeInsets.only(top: 8, left: 20),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        direction: Axis.horizontal,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 300, minWidth: 200),
            child: setDropDownList((v) => onChangedForStatus(v),
                selectedStatusIDForStatus, Utils().getStatusList()),
          ),
          isFirmShow
              ? Container(
                  constraints:
                      const BoxConstraints(maxWidth: 300, minWidth: 200),
                  child: setDropDownList((v) => onChangedForFirmFilter(v),
                      selectedStatusIDForFirmFilter, firms))
              : SizedBox(
                  width: 0,
                ),
          SizedBox(
            width: 300,
            height: 55,
            child: Card(
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  filled: true,
                  fillColor: const Color(0xFFf2f6fb),
                  labelText: 'Axtarış',
                  labelStyle: TextStyle(color: Styles.defaultWidgetForeColor),
                ),
                onFieldSubmitted: (value) {
                  onSearchSubmitted(value);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget setDropDownList(void Function(dynamic newValue) onChanged,
      dynamic selectedStatusID, List<DropdownMenuItem<dynamic>> items) {
    return Card(
      margin: const EdgeInsets.all(0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        //set border radius more than 50% of height and width to make circle
      ),
      child: ListTile(
        minVerticalPadding: 0,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        leading: const Icon(Icons.comment),
        title: SizedBox(
            height: 50,
            child: DropdownButtonFormField(
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                filled: true,
                fillColor: Color(0xFFf2f6fb),
              ),
              items: items, // Utils().getStatusList(),
              itemHeight: 50,
              onChanged: (newVal) {
                onChanged(newVal);
              },
              initialValue: selectedStatusID,
              style: const TextStyle(fontSize: 18),
            )),
      ),
    );
  }
}
