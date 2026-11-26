import 'dart:js_interop';
import 'dart:typed_data';

import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:web/web.dart' as web;

// `excel` paketi wasm-da işləmir (archive 3.x və dart:html istifadə edir),
// ona görə Syncfusion XlsIO + package:web istifadə olunur.
class ExcelOperations {
  Future<void> exportListToExcelFile(
      String fileName, List headers, List rows) async {
    final Workbook workbook = Workbook();
    try {
      final Worksheet sheet = workbook.worksheets[0];

      final Style headerStyle = workbook.styles.add('HeaderStyle');
      headerStyle.bold = true;
      headerStyle.borders.all.lineStyle = LineStyle.thin;

      final Style rowStyle = workbook.styles.add('RowStyle');
      rowStyle.borders.all.lineStyle = LineStyle.thin;

      final visibleHeaders = headers
          .where((h) => h['visible'] == true && h['key'] != 'operation')
          .toList();

      for (int c = 0; c < visibleHeaders.length; c++) {
        final header = visibleHeaders[c];
        final int col = c + 1; // XlsIO indeksləri 1-dən başlayır

        final Range headerCell = sheet.getRangeByIndex(1, col);
        headerCell.setText(header['value']?.toString() ?? '');
        headerCell.cellStyle = headerStyle;

        for (int r = 0; r < rows.length; r++) {
          final Range cell = sheet.getRangeByIndex(r + 2, col);
          _setCellValue(cell, rows[r][header['key']]);
          cell.cellStyle = rowStyle;
        }
        sheet.autoFitColumn(col);
      }

      final List<int> bytes = workbook.saveAsStream();
      _downloadFile(bytes, 'M+License_$fileName.xlsx');
    } finally {
      workbook.dispose();
    }
  }

  void _setCellValue(Range cell, dynamic value) {
    if (value == null) return;
    if (value is num) {
      cell.setNumber(value.toDouble());
    } else if (value is bool) {
      cell.setText(value ? 'Bəli' : 'Xeyr');
    } else {
      cell.setText(value.toString());
    }
  }

  void _downloadFile(List<int> bytes, String fileName) {
    final web.Blob blob = web.Blob(
      [Uint8List.fromList(bytes).toJS].toJS,
      web.BlobPropertyBag(
          type:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
    );
    final String url = web.URL.createObjectURL(blob);
    final web.HTMLAnchorElement anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }
}
