import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class TeachersViewPage extends StatefulWidget {
  const TeachersViewPage({super.key});

  @override
  _TeachersViewPageState createState() => _TeachersViewPageState();
}

class _TeachersViewPageState extends State<TeachersViewPage> {
  final pb = PocketBase('http://145.223.21.62:8085');
  List<dynamic> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Using PocketBase SDK
      final result = await pb.collection('teachers').getList(
            page: 1,
            perPage: 50,
            expand: 'avatar',
          );

      // Debug print to check teachers data
      print('Teachers found: ${result.items.length}');
      if (result.items.isNotEmpty) {
        final firstTeacher = result.items[0];
        print('First teacher data: ${firstTeacher.data}');
      }

      setState(() {
        teachers = result.items;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching with SDK: $e');
      // Fallback to HTTP in case PocketBase SDK has issues
      try {
        final response = await http.get(
          Uri.parse(
              'http://145.223.21.62:8085/api/collections/teachers/records?perPage=50&expand=avatar'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('HTTP response: ${data['items'].length} teachers found');
          setState(() {
            teachers = data['items'];
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load teachers');
        }
      } catch (httpError) {
        print('HTTP Error: $httpError');
        setState(() {
          isLoading = false;
        });
        showError('Failed to load teachers: ${httpError.toString()}');
      }
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<String> _parseSubjects(dynamic subjectsData) {
    if (subjectsData == null) return [];

    try {
      if (subjectsData is String) {
        final decoded = json.decode(subjectsData);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } else if (subjectsData is List) {
        return subjectsData.map((item) => item.toString()).toList();
      }
    } catch (e) {
      // If not a valid JSON, try to split by commas
      return subjectsData
          .toString()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return [subjectsData.toString()];
  }

  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    return initials.toUpperCase();
  }

  String? _getAvatarUrl(dynamic teacher) {
    final teacherData = teacher is RecordModel ? teacher.data : teacher;

    try {
      // Check if there's an expanded avatar field
      if (teacherData['expand'] != null &&
          teacherData['expand']['avatar'] != null) {
        final avatarData = teacherData['expand']['avatar'];
        if (avatarData is List && avatarData.isNotEmpty) {
          final url =
              'http://145.223.21.62:8085/api/files/${avatarData[0]['collectionId']}/${avatarData[0]['id']}/${avatarData[0]['file']}';
          print('Avatar URL (from expand list): $url');
          return url;
        } else if (avatarData is Map) {
          final url =
              'http://145.223.21.62:8085/api/files/${avatarData['collectionId']}/${avatarData['id']}/${avatarData['file']}';
          print('Avatar URL (from expand map): $url');
          return url;
        }
      }

      // Check if there's a direct avatar field with an ID
      if (teacherData['avatar'] != null &&
          teacherData['avatar'] is String &&
          teacherData['avatar'].isNotEmpty) {
        final url =
            'http://145.223.21.62:8085/api/files/teachers/${teacherData['id']}/${teacherData['avatar']}';
        print('Avatar URL (from direct field): $url');
        return url;
      }
    } catch (e) {
      // If any error occurs while trying to get the avatar, return null
      print('Error getting avatar: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers Directory'),
        elevation: 0,
        backgroundColor: Colors.indigo.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTeachers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : teachers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No teachers found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    final teacherData =
                        teacher is RecordModel ? teacher.data : teacher;

                    final firstName = teacherData['f_name'] ?? '';
                    final lastName = teacherData['l_name'] ?? '';
                    final field = teacherData['field'] ?? '';
                    final email = teacherData['email'] ?? '';
                    final phone = teacherData['phone_number'] ?? '';
                    final subjects = _parseSubjects(teacherData['subjects']);
                    final avatarUrl = _getAvatarUrl(teacher);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          // View teacher details
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Teacher avatar section
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: avatarUrl != null
                                    ? Image.network(
                                        avatarUrl,
                                        width: 90,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            width: 90,
                                            height: 120,
                                            color: Colors.grey.shade200,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          print('Error loading image: $error');
                                          return Container(
                                            width: 90,
                                            height: 120,
                                            color: Colors.indigo.shade100,
                                            child: Center(
                                              child: Text(
                                                _getInitials(
                                                    firstName, lastName),
                                                style: const TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 90,
                                        height: 120,
                                        color: Colors.indigo.shade100,
                                        child: Center(
                                          child: Text(
                                            _getInitials(firstName, lastName),
                                            style: const TextStyle(
                                              color: Colors.indigo,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),

                              // Teacher details section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$firstName $lastName',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      field,
                                      style: TextStyle(
                                        color: Colors.indigo.shade700,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Contact details
                                    if (email.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            Icon(Icons.email_outlined,
                                                size: 16,
                                                color: Colors.grey.shade600),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                email,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade800),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    if (phone.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            Icon(Icons.phone_outlined,
                                                size: 16,
                                                color: Colors.grey.shade600),
                                            const SizedBox(width: 8),
                                            Text(
                                              phone,
                                              style: TextStyle(
                                                  color: Colors.grey.shade800),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Subjects
                                    if (subjects.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.book_outlined,
                                              size: 16,
                                              color: Colors.grey.shade600),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Subjects: ${subjects.join(", ")}',
                                              style: TextStyle(
                                                  color: Colors.grey.shade800),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    // View profile button
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // View detailed profile
                                          },
                                          icon:
                                              const Icon(Icons.person_outline),
                                          label: const Text('View Profile'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.indigo,
                                            side: BorderSide(
                                                color: Colors.indigo.shade300),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// Model class for Teacher (optional, for stronger typing)
class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  final String field;
  final String email;
  final String phoneNumber;
  final List<String> subjects;
  final String? avatarUrl;

  Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.field,
    required this.email,
    required this.phoneNumber,
    required this.subjects,
    this.avatarUrl,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    List<String> parseSubjects(dynamic subjectsData) {
      if (subjectsData == null) return [];

      try {
        if (subjectsData is String) {
          final decoded = jsonDecode(subjectsData);
          if (decoded is List) {
            return decoded.map((item) => item.toString()).toList();
          }
        } else if (subjectsData is List) {
          return subjectsData.map((item) => item.toString()).toList();
        }
      } catch (e) {
        return subjectsData
            .toString()
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      return [subjectsData.toString()];
    }

    String? getAvatarUrl(Map<String, dynamic> json) {
      try {
        if (json['expand'] != null && json['expand']['avatar'] != null) {
          final avatarData = json['expand']['avatar'];
          if (avatarData is List && avatarData.isNotEmpty) {
            return 'http://145.223.21.62:8085/api/files/${avatarData[0]['collectionId']}/${avatarData[0]['id']}/${avatarData[0]['file']}';
          } else if (avatarData is Map) {
            return 'http://145.223.21.62:8085/api/files/${avatarData['collectionId']}/${avatarData['id']}/${avatarData['file']}';
          }
        }

        if (json['avatar'] != null &&
            json['avatar'] is String &&
            json['avatar'].isNotEmpty) {
          return 'http://145.223.21.62:8085/api/files/teachers/${json['id']}/${json['avatar']}';
        }
      } catch (e) {
        print('Error getting avatar URL: $e');
      }
      return null;
    }

    return Teacher(
      id: json['id'] ?? '',
      firstName: json['f_name'] ?? '',
      lastName: json['l_name'] ?? '',
      field: json['field'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      subjects: parseSubjects(json['subjects']),
      avatarUrl: getAvatarUrl(json),
    );
  }
}

// Usage example
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const TeachersViewPage(),
    );
  }
}
