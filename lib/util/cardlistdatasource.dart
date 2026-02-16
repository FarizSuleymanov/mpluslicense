import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CardListDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  late final List list_;
  List gridColumns;

  CardListDataSource(this.list_, this.gridColumns) {
    buildDataGridRows();
  }
  List<DataGridRow> cardList = [];

  void buildDataGridRows() {
    cardList = list_.map<DataGridRow>((l) {
      return DataGridRow(
          cells: gridColumns.map<DataGridCell>((column) {
        return DataGridCell(
          columnName: column['key'],
          value: l[column['key']],
        );
      }).toList());
    }).toList();
  }

  @override
  List<DataGridRow> get rows => cardList;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        return Container(
          alignment: Alignment.center,
          child: e.columnName.contains('Guid')
              ? SelectableText(
                  e.value
                          ?.toString()
                          .replaceAll('false', 'Xeyr')
                          .replaceAll('true', 'Bəli') ??
                      '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
                )
              : Text(
                  e.value
                          ?.toString()
                          .replaceAll('false', 'Xeyr')
                          .replaceAll('true', 'Bəli') ??
                      '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
                ),
        );
      }).toList(),
    );
  }

  void refreshDataGrid() {
    notifyListeners();
  }
}
