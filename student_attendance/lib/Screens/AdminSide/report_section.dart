import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_attendance/Screens/AdminSide/view_students.dart';
import 'package:student_attendance/Screens/AdminSide/view_teachers.dart';

class ViewReportScreen extends StatefulWidget {
  const ViewReportScreen({super.key});

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  // Sample data for the dashboard - would come from your API in a real app
  final Map<String, dynamic> _dashboardData = {
    'totalStudents': 245,
    'totalTeachers': 18,
    'attendanceToday': 0.89, // 89% attendance rate
    'recentAbsences': 12,
    'pendingRequests': 5,
    'upcomingEvents': 3,
    'attendanceHistory': [0.92, 0.88, 0.90, 0.87, 0.89, 0.89],
    'daysOfWeek': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Today'],
  };

  // Colors used in the dashboard
  final Color _primaryColor = Colors.blue;
  final Color _secondaryColor = Colors.green;
  final Color _accentColor = Colors.orange;
  final Color _dangerColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Report Dashboard'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Main overview cards
              // _buildMainCards(),
              // const SizedBox(height: 24),

              // Attendance chart section
              _buildAttendanceSection(),
              const SizedBox(height: 24),

              // Quick actions section
              _buildQuickActionsSection(),
              const SizedBox(height: 24),

              // Recent activity section
              //  _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: _primaryColor,
      //   child: const Icon(Icons.add),
      //   onPressed: () {
      //     // Show quick actions menu
      //     _showQuickActionsMenu();
      //   },
      // ),
    );
  }

  // Welcome section with date and quick stats
  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, Admin',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateFormat.format(now),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s what\'s happening in your school today',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Main overview cards
  Widget _buildMainCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Students Card
            Expanded(
              child: _buildOverviewCard(
                title: 'Students',
                value: _dashboardData['totalStudents'].toString(),
                icon: Icons.people_alt_outlined,
                color: _primaryColor,
                onTap: () {
                  // Navigate to students list page
                },
              ),
            ),
            const SizedBox(width: 16),
            // Teachers Card
            Expanded(
              child: _buildOverviewCard(
                title: 'Teachers',
                value: _dashboardData['totalTeachers'].toString(),
                icon: Icons.school_outlined,
                color: _secondaryColor,
                onTap: () {
                  // Navigate to teachers list page
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Attendance Today Card
        _buildAttendanceCard(
          attendanceRate: _dashboardData['attendanceToday'],
          absences: _dashboardData['recentAbsences'],
        ),
      ],
    );
  }

  // Card widget for overview items
  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  'View',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Attendance card with progress indicator
  Widget _buildAttendanceCard({
    required double attendanceRate,
    required int absences,
  }) {
    // Format attendance rate as percentage
    final percentage = (attendanceRate * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Attendance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to detailed attendance page
                },
                child: Text(
                  'Details',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: attendanceRate,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                      strokeWidth: 8,
                    ),
                    Center(
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Attendance stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAttendanceStatRow(
                      label: 'Present',
                      value: '${(245 * attendanceRate).round()} students',
                      color: _secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildAttendanceStatRow(
                      label: 'Absent',
                      value: '$absences students',
                      color: _dangerColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for attendance stat rows
  Widget _buildAttendanceStatRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Attendance chart section
  Widget _buildAttendanceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to detailed attendance analytics
                },
                child: Text(
                  'View More',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _buildAttendanceChart(),
          ),
        ],
      ),
    );
  }

  // Line chart for attendance
  Widget _buildAttendanceChart() {
    final attendanceHistory =
        _dashboardData['attendanceHistory'] as List<double>;
    final daysOfWeek = _dashboardData['daysOfWeek'] as List<String>;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= daysOfWeek.length)
                  return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    daysOfWeek[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == 1) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: attendanceHistory.length - 1.0,
        minY: 0.7, // Start at 70%
        maxY: 1.0,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              attendanceHistory.length,
              (i) => FlSpot(i.toDouble(), attendanceHistory[i]),
            ),
            isCurved: true,
            color: _accentColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: _accentColor.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  // Quick actions section
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'View Students',
                icon: Icons.person,
                color: _primaryColor,
                onTap: () {
                  // Navigate to add student page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentAdminPanel()));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'View Teachers',
                icon: Icons.person,
                color: _secondaryColor,
                onTap: () {
                  // Navigate to add teacher page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TeachersViewPage()));
                },
              ),
            ),
            // const SizedBox(width: 16),
            // Expanded(
            //   child: _buildActionCard(
            //     title: 'View Reports',
            //     icon: Icons.insert_chart_outlined,
            //     color: _accentColor,
            //     onTap: () {
            //       // Navigate to reports page
            //     },
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  // Quick action card
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent activity section
  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // View all activity
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.person_add,
            color: _primaryColor,
            title: 'New student added',
            description: 'John Doe was added to Grade 10-A',
            time: '10 minutes ago',
          ),
          const Divider(),
          _buildActivityItem(
            icon: Icons.school,
            color: _secondaryColor,
            title: 'Teacher update',
            description: 'Sara Smith updated her profile information',
            time: '45 minutes ago',
          ),
          const Divider(),
          _buildActivityItem(
            icon: Icons.event_note,
            color: _accentColor,
            title: 'New event scheduled',
            description: 'Parent-Teacher meeting for Grade 9',
            time: '2 hours ago',
          ),
        ],
      ),
    );
  }

  // Activity item
  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Drawer menu
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: _primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  'Admin User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'admin@school.edu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            selectedTileColor: _primaryColor.withOpacity(0.1),
            selectedColor: _primaryColor,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: const Text('Students'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to students
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Teachers'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to teachers
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: const Text('Attendance'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to attendance
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart_outlined),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to reports
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to events
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Logout
            },
          ),
        ],
      ),
    );
  }

  // Quick actions menu
  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.person_add,
                    label: 'Add Student',
                    color: _primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to add student
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.person_add_alt_1,
                    label: 'Add Teacher',
                    color: _secondaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to add teacher
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.event_note,
                    label: 'Mark Attendance',
                    color: _accentColor,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to attendance marking
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.event,
                    label: 'Add Event',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to add event
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.announcement,
                    label: 'New Notice',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to add notice
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.bar_chart,
                    label: 'Reports',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to reports
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Quick action button for bottom sheet
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
