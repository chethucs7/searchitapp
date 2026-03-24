import 'dart:convert';

class ExcelRecord {
  final int? id;
  final String searchText;
  final Map<String, dynamic> rowData;

  ExcelRecord({
    this.id,
    required this.searchText,
    required this.rowData,
  });

  // Convert ExcelRecord to JSON for storing in database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'search_text': searchText,
      'row_data': jsonEncode(rowData),
    };
  }

  // Create ExcelRecord from database map
  factory ExcelRecord.fromMap(Map<String, dynamic> map) {
    return ExcelRecord(
      id: map['id'] as int?,
      searchText: map['search_text'] as String? ?? '',
      rowData: _parseRowData(map['row_data']),
    );
  }

  // Safely parse row data JSON
  static Map<String, dynamic> _parseRowData(dynamic rowDataJson) {
    if (rowDataJson is Map<String, dynamic>) {
      return rowDataJson;
    }
    if (rowDataJson is String) {
      try {
        final decoded = jsonDecode(rowDataJson);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        // Handle JSON decode error
      }
    }
    return {};
  }

  @override
  String toString() {
    return 'ExcelRecord(id: $id, searchText: $searchText)';
  }
}
