import 'package:flutter/foundation.dart';
import '../services/report_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  DashboardStats? stats;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      stats = await _reportService.loadDashboard();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }
}
