import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceService {
  // Base URL for PocketBase
  final String baseUrl = 'http://145.223.21.62:8085';

  // Attendance collection endpoint
  static const String _attendanceCollection = 'attendance';

  // Headers for API requests
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Single attendance record creation
  Future<bool> createAttendanceRecord({
    required String studentId,
    required String grade,
    required String classRoom,
    required String date,
    required String teacherUsername,
  }) async {
    try {
      final body = {
        "Student_id": studentId,
        "grade": grade,
        "class": classRoom,
        "date": date,
        "teacher_user_name": teacherUsername,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/collections/$_attendanceCollection/records'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to create attendance record: ${response.body}',
        );
      }
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Error creating attendance record: ${e.toString()}',
      );
    }
  }

  // Bulk attendance record creation with batching
  Future<BulkAttendanceResult> createBulkAttendanceRecords({
    required List<AttendanceRecord> records,
    int batchSize = 50,
  }) async {
    final results = BulkAttendanceResult();

    // Split records into batches
    for (int i = 0; i < records.length; i += batchSize) {
      final batch = records.skip(i).take(batchSize).toList();

      try {
        // Prepare batch request body
        final batchBody = {
          "records": batch
              .map((record) => {
                    "Student_id": record.studentId,
                    "grade": record.grade,
                    "class": record.classRoom,
                    "date": record.date,
                    "teacher_user_name": record.teacherUsername,
                  })
              .toList(),
        };

        final response = await http.post(
          Uri.parse(
              '$baseUrl/api/collections/$_attendanceCollection/records/bulk'),
          headers: _headers,
          body: jsonEncode(batchBody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Parse response to get individual record results
          final responseBody = jsonDecode(response.body);
          final batchResults = responseBody['results'] as List;

          for (int j = 0; j < batch.length; j++) {
            if (batchResults[j]['success'] == true) {
              results.successfulRecords.add(batch[j]);
            } else {
              results.failedRecords.add(FailedAttendanceRecord(
                record: batch[j],
                errorMessage: batchResults[j]['error'] ?? 'Unknown error',
              ));
            }
          }
        } else {
          // If entire batch fails, mark all records as failed
          results.failedRecords
              .addAll(batch.map((record) => FailedAttendanceRecord(
                    record: record,
                    errorMessage: 'Batch request failed: ${response.body}',
                  )));
        }
      } catch (e) {
        // Handle network or parsing errors
        results.failedRecords
            .addAll(batch.map((record) => FailedAttendanceRecord(
                  record: record,
                  errorMessage: 'Network error: ${e.toString()}',
                )));
      }
    }

    return results;
  }

  // Check for existing attendance record to prevent duplicates
  Future<bool> checkExistingAttendanceRecord({
    required String studentId,
    required String date,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/collections/$_attendanceCollection/records?filter='
            'Student_id="$studentId" && date="$date"'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['totalItems'] > 0;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to check existing attendance: ${response.body}',
        );
      }
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        message: 'Error checking attendance record: ${e.toString()}',
      );
    }
  }
}

// Custom exception for API-related errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}

// Attendance record model
class AttendanceRecord {
  final String studentId;
  final String grade;
  final String classRoom;
  final String date;
  final String teacherUsername;

  AttendanceRecord({
    required this.studentId,
    required this.grade,
    required this.classRoom,
    required this.date,
    required this.teacherUsername,
  });
}

// Wrapper for bulk attendance creation results
class BulkAttendanceResult {
  List<AttendanceRecord> successfulRecords = [];
  List<FailedAttendanceRecord> failedRecords = [];

  bool get hasSuccessfulRecords => successfulRecords.isNotEmpty;
  bool get hasFailedRecords => failedRecords.isNotEmpty;

  int get totalRecordsProcessed =>
      successfulRecords.length + failedRecords.length;
}

// Failed attendance record with error details
class FailedAttendanceRecord {
  final AttendanceRecord record;
  final String errorMessage;

  FailedAttendanceRecord({
    required this.record,
    required this.errorMessage,
  });
}
