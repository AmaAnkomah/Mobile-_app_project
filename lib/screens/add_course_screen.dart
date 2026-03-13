import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';

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
  String thumbnailUrl = '';
  String videoUrl = '';

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
              TextFormField(
                decoration: InputDecoration(labelText: 'Thumbnail URL'),
                onChanged: (val) => thumbnailUrl = val,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Video URL (direct link)',
                ),
                onChanged: (val) => videoUrl = val,
              ),
              SizedBox(height: 30),
              Consumer<CourseProvider>(
                builder: (context, courseProvider, child) => ElevatedButton(
                  onPressed: courseProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final courseData = {
                              'title': title,
                              'description': description,
                              'long_description': longDescription,
                              'category': category,
                              'thumbnail_url': thumbnailUrl,
                              'video_url': videoUrl,
                              'instructor_id':
                                  'instructor_123', // Hardcoded for now or fetch from Auth
                            };

                            final success = await courseProvider.addCourse(
                              courseData,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
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
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Create Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
