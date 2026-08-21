import 'package:flutter/foundation.dart';
import '../models/bmi_record.dart';
import '../repositories/user_repository.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;

  UserProvider({UserService? userService})
      : _userService = userService ?? UserService();

  List<BmiRecord> records = [];
  bool isLoading = false;
  String? errorMessage;

  String searchQuery = '';
  String genderFilter = 'All';
  String categoryFilter = 'All';
  SortField sortField = SortField.dateAdded;
  bool ascending = false;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      records = await _userService.list(
        searchQuery: searchQuery,
        genderFilter: genderFilter,
        categoryFilter: categoryFilter,
        sortField: sortField,
        ascending: ascending,
      );
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    searchQuery = query;
    load();
  }

  void setGenderFilter(String value) {
    genderFilter = value;
    load();
  }

  void setCategoryFilter(String value) {
    categoryFilter = value;
    load();
  }

  void setSort(SortField field) {
    if (sortField == field) {
      ascending = !ascending;
    } else {
      sortField = field;
      ascending = false;
    }
    load();
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _userService.delete(id);
      records.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
