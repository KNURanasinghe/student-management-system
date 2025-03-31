import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../Models/student_model.dart';
import '../../Services/api_service.dart';

class AttendanceSummaryPage extends StatefulWidget {
  final String grade;
  final String classSection;
  final List<Student> students;

  const AttendanceSummaryPage({
    Key? key,
    required this.grade,
    required this.classSection,
    required this.students,
  }) : super(key: key);

  @override
  _AttendanceSummaryPageState createState() => _AttendanceSummaryPageState();
}

class _AttendanceSummaryPageState extends State<AttendanceSummaryPage> {
  final ApiService _apiService = ApiService();

  // Summary data
  int _totalStudents = 0;
  int _boysCount = 0;
  int _girlsCount = 0;
  int _presentStudentsCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceSummary();
  }

  Future<void> _fetchAttendanceSummary() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get today's date in Sri Lankan format (DD/MM/YYYY)
      final todayDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

      // Count total students
      _totalStudents = widget.students.length;

      // Count boys and girls
      _boysCount = widget.students.where((student) => _isBoy(student)).length;
      _girlsCount = _totalStudents - _boysCount;

      // Fetch today's attendance
      final attendanceRecords = await _fetchTodayAttendance(todayDate);

      // Count present students
      _presentStudentsCount = attendanceRecords.length;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load summary: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Placeholder method to determine student's gender
  // Modify this based on your actual student model
  bool _isBoy(Student student) {
    // Example implementation - replace with actual logic
    // This could be based on a gender field or name pattern
    return false; // Placeholder
  }

  Future<List<dynamic>> _fetchTodayAttendance(String todayDate) async {
    try {
      // Use the new performCustomApiCall method
      final response = await _apiService.performCustomApiCall(
        endpoint: '/api/collections/attendance/records',
        queryParams: {
          'filter':
              'grade="${widget.grade}" && class="${widget.classSection}" && date="$todayDate"',
        },
      );

      // PocketBase typically returns items in a 'items' key
      return response['items'] ?? [];
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Summary: ${widget.grade} ${widget.classSection}',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[600],
      ),
      body: _isLoading
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
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary Cards
                      _buildSummaryCard(
                        title: 'Total Students',
                        value: _totalStudents.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        title: 'Boys',
                        value: _boysCount.toString(),
                        icon: Icons.male,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        title: 'Girls',
                        value: _girlsCount.toString(),
                        icon: Icons.female,
                        color: Colors.pink,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        title: 'Today\'s Attendance',
                        value: '$_presentStudentsCount / $_totalStudents',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
    );
  }

  // Helper method to build summary cards
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color? color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
