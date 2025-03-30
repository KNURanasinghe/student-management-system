import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:student_attendance/Services/api_service.dart';
import 'package:student_attendance/Models/student_model.dart';

class StudentAdminPanel extends StatefulWidget {
  const StudentAdminPanel({super.key});

  @override
  _StudentAdminPanelState createState() => _StudentAdminPanelState();
}

class _StudentAdminPanelState extends State<StudentAdminPanel> {
  final ApiService _apiService = ApiService();
  List<Student> students = [];
  bool isLoading = true;
  String? selectedGrade;
  String? selectedClass;

  final List<String> _grades = [
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12'
  ];

  final Map<String, List<String>> _classOptions = {
    'Grade 6': ['Class A', 'Class B', 'Class C'],
    'Grade 7': ['Class A', 'Class B', 'Class C'],
    'Grade 8': ['Class A', 'Class B', 'Class C'],
    'Grade 9': ['Class A', 'Class B', 'Class C'],
    'Grade 10': ['Class A', 'Class B', 'Class C'],
    'Grade 11': ['Class A', 'Class B', 'Class C'],
    'Grade 12': ['Class A', 'Class B', 'Class C'],
  };

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Construct the filter query for the HTTP request
      String filterQuery = '';

      if (selectedGrade != null) {
        filterQuery = 'filter=grade="$selectedGrade"';

        if (selectedClass != null) {
          filterQuery =
              'filter=grade="$selectedGrade"+%26%26+class="$selectedClass"';
        }
      }

      // Make HTTP request directly to PocketBase API
      final response = await http.get(
        Uri.parse(
            '${_apiService.baseUrl}/api/collections/students/records?$filterQuery&perPage=50'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> studentList = responseData['items'] ?? [];

        setState(() {
          students = studentList.map((data) => Student.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching students: $e');
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load students: ${e.toString()}'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _deleteStudent(String studentId) async {
    try {
      final response = await _apiService.deleteStudent(studentId);
      if (response == true) {
        showError('Delete Success');
        fetchStudents(); // Refresh the list after deleting
      }
    } catch (e) {
      print('Error when deleting student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${e.toString()}')),
      );
    }
  }

  void _showDeleteConfirmation(String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(studentId);
            },
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message'),
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

  void _onGradeChanged(String? grade) {
    setState(() {
      selectedGrade = grade;
      selectedClass = null; // Reset class when grade changes
    });
    fetchStudents();
  }

  void _onClassChanged(String? classOption) {
    setState(() {
      selectedClass = classOption;
    });
    fetchStudents();
  }

  String _getInitials(String? firstName, String? lastName) {
    String initials = '';
    if (firstName != null && firstName.isNotEmpty) {
      initials += firstName[0];
    }
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0];
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Admin Panel'),
        elevation: 2,
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchStudents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: selectedGrade,
                    items: _grades.map((grade) {
                      return DropdownMenuItem<String>(
                        value: grade,
                        child: Text(grade),
                      );
                    }).toList(),
                    onChanged: _onGradeChanged,
                    hint: const Text('Select Grade'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: selectedClass,
                    items: selectedGrade != null
                        ? _classOptions[selectedGrade]!.map((classOption) {
                            return DropdownMenuItem<String>(
                              value: classOption,
                              child: Text(classOption),
                            );
                          }).toList()
                        : [],
                    onChanged: selectedGrade != null ? _onClassChanged : null,
                    hint: const Text('Select Class'),
                  ),
                ),
              ],
            ),
          ),

          // Students list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? const Center(child: Text('No students found'))
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];

                          // Safely extract student data to avoid null/empty string issues
                          final firstName = student.firstName ?? '';
                          final lastName = student.lastName ?? '';
                          final indexNumber = student.indexNumber ?? 'N/A';
                          final grade = student.grade ?? 'N/A';
                          final classRoom = student.classRoom ?? 'N/A';

                          // Get student image URL using the API service
                          final imageUrl =
                              _apiService.getStudentImageUrl(student);

                          // Get initials safely
                          final initials = _getInitials(firstName, lastName);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: Image.network(
                                          imageUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                'Error loading student image: $error');
                                            return CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  Colors.blue.shade100,
                                              child: Text(
                                                initials.isNotEmpty
                                                    ? initials
                                                    : '?',
                                                style: TextStyle(
                                                  color: Colors.blue.shade800,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.blue.shade100,
                                        child: Text(
                                          initials.isNotEmpty ? initials : '?',
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                              title: Text(
                                firstName.isNotEmpty || lastName.isNotEmpty
                                    ? '$firstName $lastName'
                                    : 'Unknown Student',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Index Number: $indexNumber'),
                                  Text('Grade: $grade - $classRoom'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      // Handle edit student
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => student.id != null
                                        ? _showDeleteConfirmation(student.id!)
                                        : null,
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              onTap: () {
                                // Show student details
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new student functionality
        },
        backgroundColor: Colors.blue.shade800,
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
