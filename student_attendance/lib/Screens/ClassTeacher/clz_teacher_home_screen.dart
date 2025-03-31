import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:student_attendance/Services/attendance_service.dart';

// Import your models and API service
import '../../Models/student_model.dart';
import '../../Services/api_service.dart';
import 'attendance_summary.dart';

class ClzTeacherHomeScreen extends StatefulWidget {
  const ClzTeacherHomeScreen({super.key});

  @override
  State<ClzTeacherHomeScreen> createState() => _ClzTeacherHomeScreenState();
}

class _ClzTeacherHomeScreenState extends State<ClzTeacherHomeScreen> {
  final List<String> _grades = [
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
  ];

  final Map<String, List<String>> _classOptions = {
    'Grade 6': ['Class A', 'Class B', 'Class C'],
    'Grade 7': ['Class A', 'Class B', 'Class C'],
    'Grade 8': ['Class A', 'Class B', 'Class C'],
    'Grade 9': ['Class A', 'Class B', 'Class C'],
    'Grade 10': ['Class A', 'Class B', 'Class C'],
    'Grade 11': ['Class A', 'Class B', 'Class C'],
  };

  // Selected values
  String? _selectedGrade;
  String? _selectedClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Selection',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[600],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[50]!,
              Colors.indigo[100]!,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Class and Grade',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Grade Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Grade',
                        prefixIcon:
                            Icon(Icons.school, color: Colors.indigo[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: _selectedGrade,
                      hint: const Text('Choose Grade'),
                      items: _grades
                          .map((grade) => DropdownMenuItem(
                                value: grade,
                                child: Text(grade),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGrade = value;
                          // Reset class selection when grade changes
                          _selectedClass = null;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Class Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Class',
                        prefixIcon:
                            Icon(Icons.class_, color: Colors.indigo[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: _selectedClass,
                      hint: const Text('Choose Class'),
                      // Disable dropdown if no grade is selected
                      items: _selectedGrade == null
                          ? null
                          : _classOptions[_selectedGrade]!
                              .map((classSection) => DropdownMenuItem(
                                    value: classSection,
                                    child: Text(classSection),
                                  ))
                              .toList(),
                      onChanged: _selectedGrade == null
                          ? null
                          : (value) {
                              setState(() {
                                _selectedClass = value;
                              });
                            },
                    ),

                    const SizedBox(height: 30),

                    // Next Button
                    ElevatedButton(
                      onPressed: _selectedGrade != null &&
                              _selectedClass != null
                          ? () {
                              // Navigate to Class Teacher Home Page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassTeacherHomePage(
                                    // Convert to match your API model
                                    grade: _selectedGrade!,
                                    classSection: _selectedClass!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[600],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClassTeacherHomePage extends StatefulWidget {
  final String grade;
  final String classSection;

  const ClassTeacherHomePage({
    super.key,
    required this.grade,
    required this.classSection,
  });

  @override
  _ClassTeacherHomePageState createState() => _ClassTeacherHomePageState();
}

class _ClassTeacherHomePageState extends State<ClassTeacherHomePage> {
  final ApiService _apiService = ApiService();
  final AttendanceService _attendanceService = AttendanceService();
  List<StudentAttendance> _students = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _allStudentsMarked = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch all students
      final allStudents = await _apiService.getAllStudents();

      // Filter students by grade and class
      final filteredStudents = allStudents
          .where((student) =>
              student.grade == widget.grade &&
              student.classRoom == widget.classSection)
          .toList();

      setState(() {
        _students = filteredStudents
            .map((student) => StudentAttendance(
                  student: student,
                  attendanceStatus: AttendanceStatus.none,
                  isMarking: false,
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load students: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAttendance(int index, AttendanceStatus status) async {
    // Prevent marking if already marking
    if (_students[index].isMarking) return;

    setState(() {
      _students[index].isMarking = true;
    });

    try {
      // Prepare attendance record
      final attendanceRecord = AttendanceRecord(
        studentId: _students[index].student.id ?? '',
        grade: widget.grade,
        classRoom: widget.classSection,
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        teacherUsername:
            'current_teacher_username', // Replace with actual username
      );

      // Create attendance record
      final success = await _attendanceService.createAttendanceRecord(
        studentId: attendanceRecord.studentId,
        grade: attendanceRecord.grade,
        classRoom: attendanceRecord.classRoom,
        date: attendanceRecord.date,
        teacherUsername: attendanceRecord.teacherUsername,
      );

      if (success) {
        setState(() {
          _students[index].attendanceStatus = status;
          _students[index].isMarking = false;

          // Check if all students have been marked
          _allStudentsMarked = _students.every(
              (student) => student.attendanceStatus != AttendanceStatus.none);
        });

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Attendance marked ${status == AttendanceStatus.present ? 'Present' : 'Absent'} for ${_students[index].student.firstName}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor:
                status == AttendanceStatus.present ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _students[index].isMarking = false;
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to mark attendance: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance: ${widget.grade} ${widget.classSection}',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[600],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.indigo[600],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.roboto(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : _students.isEmpty
                        ? Center(
                            child: Text(
                              'No students found in ${widget.grade} ${widget.classSection}',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: _students.length,
                            itemBuilder: (context, index) {
                              final studentAttendance = _students[index];
                              final student = studentAttendance.student;

                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        student.profileImageUrl != null
                                            ? NetworkImage(_apiService
                                                .getStudentImageUrl(student))
                                            : null,
                                    child: student.profileImageUrl == null
                                        ? Icon(Icons.person,
                                            color: Colors.indigo[600])
                                        : null,
                                  ),
                                  title: Text(
                                    '${student.firstName} ${student.lastName}',
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Index: ${student.indexNumber}',
                                        style: GoogleFonts.roboto(),
                                      ),
                                      if (studentAttendance.isMarking)
                                        Text(
                                          'Marking attendance...',
                                          style: GoogleFonts.roboto(
                                            color: Colors.orange,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      else if (studentAttendance
                                              .attendanceStatus !=
                                          AttendanceStatus.none)
                                        Text(
                                          studentAttendance.attendanceStatus ==
                                                  AttendanceStatus.present
                                              ? 'Present'
                                              : 'Absent',
                                          style: GoogleFonts.roboto(
                                            color: studentAttendance
                                                        .attendanceStatus ==
                                                    AttendanceStatus.present
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Present Button
                                      IconButton(
                                        icon: Icon(
                                          Icons.check_circle,
                                          color: studentAttendance.isMarking
                                              ? Colors.grey
                                              : (studentAttendance
                                                          .attendanceStatus ==
                                                      AttendanceStatus.present
                                                  ? Colors.green
                                                  : Colors.grey),
                                        ),
                                        onPressed:
                                            studentAttendance.isMarking ||
                                                    studentAttendance
                                                            .attendanceStatus ==
                                                        AttendanceStatus.present
                                                ? null
                                                : () => _markAttendance(index,
                                                    AttendanceStatus.present),
                                      ),
                                      // Absent Button
                                      IconButton(
                                        icon: Icon(
                                          Icons.cancel,
                                          color: studentAttendance.isMarking
                                              ? Colors.grey
                                              : (studentAttendance
                                                          .attendanceStatus ==
                                                      AttendanceStatus.absent
                                                  ? Colors.red
                                                  : Colors.grey),
                                        ),
                                        onPressed: studentAttendance
                                                    .isMarking ||
                                                studentAttendance
                                                        .attendanceStatus ==
                                                    AttendanceStatus.absent
                                            ? null
                                            : () => _markAttendance(
                                                index, AttendanceStatus.absent),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          // Summary Button - appears only when all students are marked
          if (_allStudentsMarked)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceSummaryPage(
                        grade: widget.grade,
                        classSection: widget.classSection,
                        students: _students.map((sa) => sa.student).toList(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[600],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'View Attendance Summary',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Enum to track attendance status
enum AttendanceStatus {
  none,
  present,
  absent,
}

// Wrapper class to manage attendance state
class StudentAttendance {
  final Student student;
  AttendanceStatus attendanceStatus;
  bool isMarking;

  StudentAttendance({
    required this.student,
    this.attendanceStatus = AttendanceStatus.none,
    this.isMarking = false,
  });
}
