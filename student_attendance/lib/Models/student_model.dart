class Student {
  final String? id;
  final String indexNumber;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String grade;
  final String classRoom;
  final String? profileImageUrl;

  Student({
    this.id,
    required this.indexNumber,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    required this.grade,
    required this.classRoom,
    this.profileImageUrl,
  });

  // Convert Student object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index_number': indexNumber,
      'first_name': firstName,
      'last_name': lastName,
      'g_emial': email,
      'g_mobile': phoneNumber,
      'grade': grade,
      'class': classRoom,
      'student_photo': profileImageUrl,
    };
  }

  // Create Student object from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      indexNumber: json['index_number'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['g_emial'],
      phoneNumber: json['g_mobile'],
      grade: json['grade'],
      classRoom: json['class'],
      profileImageUrl: json['student_photo'],
    );
  }
}
