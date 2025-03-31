import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../Models/student_model.dart';

// API Service class for handling student-related API calls with PocketBase
class ApiService {
  // Base URL for the PocketBase API
  final String baseUrl = 'http://145.223.21.62:8085';

  // API endpoints for PocketBase
  static const String _studentsCollection = 'students';
  static const String _recordsEndpoint = '/api/collections';

  // Headers for the API requests
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<int> getTotalStudentCount() async {
    try {
      // PocketBase supports pagination with a limit parameter
      // Setting limit=1 with fields that fetch minimal data is efficient
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/collections/students/records?fields=id&limit=100'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // PocketBase response includes a 'totalItems' field with the total count
        return responseData['totalItems'] ?? 0;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to get student count',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Create a new student with image upload in a single request
  Future<Student> createStudent(Student student, File? profileImage) async {
    try {
      // Create a multipart request for creating a student with image
      final uri = Uri.parse('$baseUrl/api/collections/students/records');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header if needed
      if (_headers.containsKey('Authorization')) {
        request.headers['Authorization'] = _headers['Authorization']!;
      }

      // Add all student fields to the request
      final studentData = student.toJson();
      studentData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add profile image if provided
      if (profileImage != null) {
        final filename =
            'student_${student.indexNumber}_${DateTime.now().millisecondsSinceEpoch}${extension(profileImage.path)}';
        request.files.add(
          await http.MultipartFile.fromPath(
            'student_photo', // Field name in PocketBase schema
            profileImage.path,
            filename: filename,
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Check response status
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse and return the created student
        return Student.fromJson(jsonDecode(response.body));
      } else {
        // Handle error responses
        final errorBody = jsonDecode(response.body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ??
              'Failed to create student: ${response.body}',
        );
      }
    } catch (e) {
      // Rethrow as ApiException if it's not already one
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Update student with profile image
  Future<Student> updateStudent(
      String id, Student student, File? newProfileImage) async {
    try {
      // Create a multipart request for updating a student with image
      final uri = Uri.parse(
          '$baseUrl$_recordsEndpoint/$_studentsCollection/records/$id');
      final request = http.MultipartRequest('PATCH', uri);

      // Add authorization header if needed
      if (_headers.containsKey('Authorization')) {
        request.headers['Authorization'] = _headers['Authorization']!;
      }

      // Add all student fields that need to be updated
      final studentData = student.toJson();
      studentData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add new profile image if provided
      if (newProfileImage != null) {
        final filename =
            'student_${student.indexNumber}_${DateTime.now().millisecondsSinceEpoch}${extension(newProfileImage.path)}';
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage', // Field name in PocketBase schema
            newProfileImage.path,
            filename: filename,
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Check response status
      if (response.statusCode == 200) {
        return Student.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to update student: ${response.body}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Get all students
  Future<List<Student>> getAllStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$_recordsEndpoint/$_studentsCollection/records'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // PocketBase returns data in a specific format with items array
        final List<dynamic> studentList = responseData['items'] ?? [];

        return studentList.map((data) => Student.fromJson(data)).toList();
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to get students',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Get student by ID
  Future<Student> getStudentById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$_recordsEndpoint/$_studentsCollection/records/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Student.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to get student details',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Delete student
  Future<bool> deleteStudent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/collections/students/records/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to delete student: ${response.body}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Get the full URL for a student's profile image
  String getImageUrl(String studentId, String filename) {
    return '$baseUrl/api/files/$_studentsCollection/$studentId/$filename';
  }

  // Helper method to construct image URL from student record
  String getStudentImageUrl(Student student) {
    if (student.id != null && student.profileImageUrl != null) {
      return '$baseUrl/api/files/$_studentsCollection/${student.id}/${student.profileImageUrl}';
    }
    return ''; // Return empty string if no image available
  }

  Future<dynamic> performCustomApiCall({
    required String endpoint,
    String method = 'GET',
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    try {
      // Construct the full URL with query parameters
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // Prepare the request based on the method
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          response = await http.post(uri,
              headers: _headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri,
              headers: _headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      // Check response status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Return decoded JSON if possible
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      } else {
        throw Exception(
            'API call failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      // Rethrow the error for the caller to handle
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBasket3() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$_recordsEndpoint/category3/records'),
      );
      print('Basket2 Response Status Code: ${response.statusCode}');
      print('Basket3 Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        return {'records': decodedBody};
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to get basket details',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> getBasket2() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$_recordsEndpoint/category2/records'),
      );
      print('Basket2 Response Status Code: ${response.statusCode}');
      print('Basket2 response Body: ${response.body}');
      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        return {'records': decodedBody};
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to get basket details',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> getBasket1() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$_recordsEndpoint/category1/records'),
      );

      print('Basket1 Response Status Code: ${response.statusCode}');
      print('Basket1 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);

        // Log the structure of the response
        print('Decoded Basket1 Response: $decodedBody');

        return {'records': decodedBody};
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              'Failed to get basket details. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getBasket1: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        statusCode: 500,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() {
    return 'ApiException: [$statusCode] $message';
  }
}
