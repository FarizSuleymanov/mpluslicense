import 'package:excel/excel.dart';

class ExcelOperations {
  Future<void> exportListToExcelFile(
      String fileName, List headers, List rows) async {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    int indexHeader = 0;

    CellStyle cellStyleHeader = CellStyle(
      bold: true,
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
    );

    CellStyle cellStyleRow = CellStyle(
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
    );

    headers.map((header) {
      if (header['visible'] == true && header['key'] != "operation") {
        sheet!.setColumnAutoFit(indexHeader);

        CellIndex cellIndexHeader =
            CellIndex.indexByColumnRow(columnIndex: indexHeader, rowIndex: 0);

        sheet.cell(cellIndexHeader).value = TextCellValue(header['value']);
        sheet.cell(cellIndexHeader).cellStyle = cellStyleHeader;

        for (int j = 0; j < rows.length; j++) {
          Map<String, dynamic> row = rows[j];

          CellIndex cellIndexRow = CellIndex.indexByColumnRow(
              columnIndex: indexHeader, rowIndex: j + 1);

          sheet.cell(cellIndexRow).value = TextCellValue(row[header['key']]);
          sheet.cell(cellIndexRow).cellStyle = cellStyleRow;
        }
        indexHeader++;
      }
    }).toList();

    excel.save(
      fileName: 'M+License_$fileName.xlsx',
    );
  }
}
