import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../core/constants/app_constants.dart';
import '../models/bmi_record.dart';

class ExportResult {
  final String filePath;
  final String fileName;
  ExportResult(this.filePath, this.fileName);
}

/// Admin-only. Exports must reflect exactly the currently filtered/sorted
/// dataset the caller passes in — never the full unfiltered table.
class ExportService {
  Future<ExportResult> exportCsv(List<BmiRecord> records) async {
    if (records.isEmpty) {
      throw Exception('No data available for export.');
    }

    final rows = <List<dynamic>>[
      ['Name', 'Age', 'Gender', 'Height (cm)', 'Weight (kg)', 'BMI', 'Category', 'Date Added'],
      for (final r in records)
        [
          r.name,
          r.age,
          r.gender.label,
          r.heightCm,
          r.weightKg,
          r.bmi,
          r.bmiCategory,
          DateFormat('yyyy-MM-dd').format(r.createdAt),
        ],
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'bmi_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvData);
    return ExportResult(file.path, fileName);
  }

  Future<ExportResult> exportPdf(List<BmiRecord> records) async {
    if (records.isEmpty) {
      throw Exception('No data available for export.');
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'BMI Management System — Export'),
          pw.Text(
            'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: [
              'Name', 'Age', 'Gender', 'Height', 'Weight', 'BMI', 'Category', 'Date'
            ],
            data: [
              for (final r in records)
                [
                  r.name,
                  r.age.toString(),
                  r.gender.label,
                  '${r.heightCm} cm',
                  '${r.weightKg} kg',
                  r.bmi.toStringAsFixed(1),
                  r.bmiCategory,
                  DateFormat('yyyy-MM-dd').format(r.createdAt),
                ],
            ],
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'bmi_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await doc.save());
    return ExportResult(file.path, fileName);
  }
}
