import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../Models/teachers_model.dart';

class TeacherApiService {
  final String baseUrl = 'http://145.223.21.62:8085';

  // Constructor
  Future<int> getTotalTeacherCount() async {
    try {
      final Uri url = Uri.parse(
          '$baseUrl/api/collections/teachers/records?fields=id&limit=1');
      debugPrint('Fetching teacher count from: $url');

      final response = await http.get(url);
      debugPrint('Teacher count response status: ${response.statusCode}');
      debugPrint('Teacher count response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final count = jsonResponse['totalItems'] ?? 0;
        debugPrint('Teacher count: $count');
        return count;
      } else {
        throw HttpException('Failed to get teacher count: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting teacher count: $e');
      throw HttpException('Error getting teacher count: ${e.toString()}');
    }
  }

  // Create a new teacher
  Future<Teacher> createTeacher(Teacher teacher, {File? profileImage}) async {
    try {
      final Uri url = Uri.parse('$baseUrl/api/collections/teachers/records');

      if (profileImage != null) {
        // Create multipart request for file upload
        final request = http.MultipartRequest('POST', url);

        // Add teacher data fields
        final teacherData = teacher.toJson();
        teacherData.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        // Add image file
        final imageStream = http.ByteStream(profileImage.openRead());
        final imageLength = await profileImage.length();

        final multipartFile = http.MultipartFile(
          'avatar',
          imageStream,
          imageLength,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);

        // Send the request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        // Check response
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = jsonDecode(response.body);
          return Teacher.fromJson(jsonResponse);
        } else {
          throw HttpException('Failed to create teacher: ${response.body}');
        }
      } else {
        // Without image, send a regular POST request
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(teacher.toJson()),
        );

        // Check response
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = jsonDecode(response.body);
          return Teacher.fromJson(jsonResponse);
        } else {
          throw HttpException('Failed to create teacher: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error creating teacher: $e');
      throw HttpException('Error creating teacher: ${e.toString()}');
    }
  }

  // Get all teachers
  Future<List<Teacher>> getAllTeachers() async {
    try {
      final Uri url = Uri.parse('$baseUrl/collections/teachers/records');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final items = jsonResponse['items'] as List;
        return items.map((item) => Teacher.fromJson(item)).toList();
      } else {
        throw HttpException('Failed to get teachers: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting teachers: $e');
      throw HttpException('Error getting teachers: ${e.toString()}');
    }
  }

  // Get teacher by ID
  Future<Teacher> getTeacherById(String id) async {
    try {
      final Uri url = Uri.parse('$baseUrl/collections/teachers/records/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Teacher.fromJson(jsonResponse);
      } else {
        throw HttpException('Failed to get teacher: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting teacher: $e');
      throw HttpException('Error getting teacher: ${e.toString()}');
    }
  }

  // Update teacher
  Future<Teacher> updateTeacher(String id, Teacher teacher,
      {File? newProfileImage}) async {
    try {
      final Uri url = Uri.parse('$baseUrl/collections/teachers/records/$id');

      if (newProfileImage != null) {
        // Create multipart request for file upload
        final request = http.MultipartRequest('PATCH', url);

        // Add teacher data fields
        final teacherData = teacher.toJson();
        teacherData.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        // Add image file
        final imageStream = http.ByteStream(newProfileImage.openRead());
        final imageLength = await newProfileImage.length();

        final multipartFile = http.MultipartFile(
          'avatar',
          imageStream,
          imageLength,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);

        // Send the request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        // Check response
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          return Teacher.fromJson(jsonResponse);
        } else {
          throw HttpException('Failed to update teacher: ${response.body}');
        }
      } else {
        // Without image, send a regular PATCH request
        final response = await http.patch(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(teacher.toJson()),
        );

        // Check response
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          return Teacher.fromJson(jsonResponse);
        } else {
          throw HttpException('Failed to update teacher: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error updating teacher: $e');
      throw HttpException('Error updating teacher: ${e.toString()}');
    }
  }

  // Delete teacher
  Future<bool> deleteTeacher(String id) async {
    try {
      final Uri url = Uri.parse('$baseUrl/collections/teachers/records/$id');
      final response = await http.delete(url);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting teacher: $e');
      throw HttpException('Error deleting teacher: ${e.toString()}');
    }
  }
}
