import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/course_provider.dart';
import '../providers/auth_provider.dart';

class AddCourseScreen extends StatefulWidget {
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String longDescription = '';
  String category = 'Programming';
  String videoUrl = '';
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  final List<String> categories = [
    'Programming',
    'Business',
    'Design',
    'Marketing',
    'Health',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Course')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Course Title'),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
                onChanged: (val) => title = val,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Short Description'),
                onChanged: (val) => description = val,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Long Description'),
                maxLines: 3,
                onChanged: (val) => longDescription = val,
              ),
              SizedBox(height: 16),
              Material(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined,
                                  size: 40, color: Color(0xFF64748B)),
                              const SizedBox(height: 8),
                              const Text('Upload Thumbnail',
                                  style: TextStyle(color: Color(0xFF64748B))),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Video URL (direct link)',
                ),
                onChanged: (val) => videoUrl = val,
              ),
              SizedBox(height: 30),
              Consumer2<CourseProvider, AuthProvider>(
                builder: (context, courseProvider, authProvider, child) => ElevatedButton(
                  onPressed: courseProvider.isLoading
                      ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_imageFile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a thumbnail image'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Upload image first
                            final downloadUrl =
                                await courseProvider.uploadImage(_imageFile!);

                            if (downloadUrl == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to upload image'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final courseData = {
                              'title': title,
                              'description': description,
                              'long_description': longDescription,
                              'category': category,
                              'thumbnail_url': downloadUrl,
                              'video_url': videoUrl,
                              'instructor_id': authProvider.userId ?? 'anonymous',
                            };

                            final success = await courseProvider.addCourse(
                              courseData,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Course added successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    courseProvider.error ??
                                        'Failed to add course',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: courseProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
