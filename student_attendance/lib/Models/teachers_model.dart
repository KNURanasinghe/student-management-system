import 'dart:convert';
import 'package:flutter/material.dart';

class Teacher {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final List<String> subjects;
  final String? profileImageUrl;

  Teacher({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.subjects,
    this.profileImageUrl,
  });

  // Convert Teacher object to JSON for HTTP request
  Map<String, dynamic> toJson() {
    return {
      'f_name': firstName,
      'l_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'subjects': jsonEncode(subjects), // Convert subjects list to JSON string
      'avatar': profileImageUrl,
    };
  }

  // Create Teacher object from JSON response
  factory Teacher.fromJson(Map<String, dynamic> json) {
    List<String> parseSubjects() {
      try {
        final subjectsData = json['subjects'];
        if (subjectsData is String) {
          return List<String>.from(jsonDecode(subjectsData));
        } else if (subjectsData is List) {
          return List<String>.from(subjectsData);
        }
        return [];
      } catch (e) {
        debugPrint('Error parsing subjects: $e');
        return [];
      }
    }

    return Teacher(
      id: json['id'],
      firstName: json['f_name'] ?? '',
      lastName: json['l_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      subjects: parseSubjects(),
      profileImageUrl: json['avatar'],
    );
  }
}
