import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:student_attendance/Services/api_service.dart';

import '../../Models/student_model.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Form field controllers
  final _indexNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  String? _selectedGrade;
  String? _selectedClass;
  String? _selectedGender;
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedSubjectCategory1;
  String? _selectedSubjectCategory3;
  String? _selectedSubjectCategory2;

  // Lists of available grades, classes, and genders
  final List<String> _grades = [
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
  ];

  final List<String> _genders = [
    'Boy',
    'Girl',
  ];

  final Map<String, List<String>> _classOptions = {
    'Grade 6': ['Class A', 'Class B', 'Class C'],
    'Grade 7': ['Class A', 'Class B', 'Class C'],
    'Grade 8': ['Class A', 'Class B', 'Class C'],
    'Grade 9': ['Class A', 'Class B', 'Class C'],
    'Grade 10': ['Class A', 'Class B', 'Class C'],
    'Grade 11': ['Class A', 'Class B', 'Class C'],
  };
  List<dynamic> _subjectCategories1 = [];
  List<dynamic> _subjectCategories2 = [];
  List<dynamic> _subjectCategories3 = [];
  @override
  void initState() {
    super.initState();
    _fetchSubjectCategories();
  }

  Future<void> _fetchSubjectCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Print detailed information about the fetch process
      print('Fetching Subject Categories...');

      // Fetch categories
      final response = await _apiService.getBasket1();
      final response1 = await _apiService.getBasket2();
      final response2 = await _apiService.getBasket3();

      // Print raw responses for debugging
      print('Basket1 Response: $response');
      print('Basket2 Response: $response1');
      print('Basket3 Response: $response2');

      setState(() {
        // Safely extract records, with null check and empty list fallback
        _subjectCategories1 = (response['records'] as List?) ?? [];
        _subjectCategories2 = (response1['records'] as List?) ?? [];
        _subjectCategories3 = (response2['records'] as List?) ?? [];

        // Print extracted categories for verification
        print('Subject Categories 1: $_subjectCategories1');
        print('Subject Categories 2: $_subjectCategories2');
        print('Subject Categories 3: $_subjectCategories3');

        // Set default selections only if lists are not empty
        if (_subjectCategories1.isNotEmpty) {
          _selectedSubjectCategory1 = _subjectCategories1[0]['id'];
        }
        if (_subjectCategories2.isNotEmpty) {
          _selectedSubjectCategory2 = _subjectCategories2[0]['id'];
        }
        if (_subjectCategories3.isNotEmpty) {
          _selectedSubjectCategory3 = _subjectCategories3[0]['id'];
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching subject categories: $e');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load subject categories: $e';
      });

      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _indexNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Method to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // Show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 10),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const Divider(),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo_camera),
                        SizedBox(width: 10),
                        Text('Camera'),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if image is selected
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload student photo')),
        );
        return;
      }

      // Check if grade and class are selected
      if (_selectedGrade == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a grade')),
        );
        return;
      }

      if (_selectedClass == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a class')),
        );
        return;
      }

      // Check if gender is selected
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select gender')),
        );
        return;
      }

      try {
        // Create Student object from form data
        final student = Student(
          indexNumber: _indexNumberController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email:
              _emailController.text.isNotEmpty ? _emailController.text : null,
          phoneNumber: _phoneNumberController.text.isNotEmpty
              ? _phoneNumberController.text
              : null,
          grade: _selectedGrade!,
          classRoom: _selectedClass!,
          // Add gender to the student model
          gender: _selectedGender!,
          category1: _selectedSubjectCategory1!,
          category2: _selectedSubjectCategory2!,
          category3: _selectedSubjectCategory3!,
        );

        // Call API to create student with image
        final createdStudent =
            await _apiService.createStudent(student, _imageFile);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Success'),
                  ],
                ),
                content: Text(
                    'Student ${createdStudent.firstName} ${createdStudent.lastName} has been added successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Return to admin home
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e is ApiException
                ? e.message
                : 'An error occurred while adding the student';
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter class options based on selected grade
    List<String> classes =
        _selectedGrade != null ? _classOptions[_selectedGrade] ?? [] : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Student'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo upload section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : null,
                              child: _imageFile == null
                                  ? const Icon(Icons.person,
                                      size: 60, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Student Photo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Student basic information
                const Text(
                  'Student Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Index Number
                TextFormField(
                  controller: _indexNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Index Number *',
                    hintText: 'Enter student index number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter index number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'Enter student first name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    hintText: 'Enter student last name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
// Gender Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  value: _selectedGender,
                  hint: const Text('Select Gender'),
                  items: _genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Email
                // Subject Category 1 Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Subject Category1 *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  value: _selectedSubjectCategory1,
                  hint: const Text('Select Subject Category'),
                  items: _subjectCategories1.isEmpty
                      ? [
                          DropdownMenuItem(
                            value: null,
                            child: Text('No categories available'),
                          )
                        ]
                      : _subjectCategories1.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'],
                            child: Text(
                                category['subjectname'] ?? 'Unknown Category'),
                          );
                        }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSubjectCategory1 = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a subject category';
                    }
                    return null;
                  },
                ),

// Subject Category 2 Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Subject Category2 *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  value: _selectedSubjectCategory2,
                  hint: const Text('Select Subject Category'),
                  items: _subjectCategories2.isEmpty
                      ? [
                          DropdownMenuItem(
                            value: null,
                            child: Text('No categories available'),
                          )
                        ]
                      : _subjectCategories2.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'],
                            child: Text(
                                category['subjectname'] ?? 'Unknown Category'),
                          );
                        }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSubjectCategory2 = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a subject category';
                    }
                    return null;
                  },
                ),

// Subject Category 3 Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Subject Category3 *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  value: _selectedSubjectCategory3,
                  hint: const Text('Select Subject Category'),
                  items: _subjectCategories3.isEmpty
                      ? [
                          DropdownMenuItem(
                            value: null,
                            child: Text('No categories available'),
                          )
                        ]
                      : _subjectCategories3.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'],
                            child: Text(
                                category['subjectname'] ?? 'Unknown Category'),
                          );
                        }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSubjectCategory3 = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a subject category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Phone Number
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Guardian Phone Number',
                    hintText: 'Enter contact phone number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // Grade & Class selection
                const Text(
                  'Grade & Class Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Grade Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Grade *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grade),
                  ),
                  value: _selectedGrade,
                  hint: const Text('Select Grade'),
                  items: _grades.map((String grade) {
                    return DropdownMenuItem<String>(
                      value: grade,
                      child: Text(grade),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGrade = newValue;
                      // Reset class when grade changes
                      _selectedClass = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Class Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Class *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.class_outlined),
                  ),
                  value: _selectedClass,
                  hint: const Text('Select Class'),
                  items: classes.map((String className) {
                    return DropdownMenuItem<String>(
                      value: className,
                      child: Text(className),
                    );
                  }).toList(),
                  onChanged: _selectedGrade == null
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedClass = newValue;
                          });
                        },
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SAVE STUDENT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
