import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'quiz_screen.dart';
import 'certificate_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  CourseDetailScreen({required this.course});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  Quiz? _quiz;
  Map<String, dynamic>? _userProgress;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.course.videoUrl))
          ..initialize().then((_) {
            setState(() {
              _isInitialized = true;
            });
          });
    _loadQuizAndProgress();
  }

  Future<void> _loadQuizAndProgress() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final quiz = await _api.fetchQuiz(widget.course.id);
    final progress = await _api.getUserProgress(
      auth.userId ?? '',
      widget.course.id,
    );
    if (mounted) {
      setState(() {
        _quiz = quiz;
        _userProgress = progress;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPlayer(),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.course.category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_userProgress != null) ...[
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'COMPLETED',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.course.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        'By Instructor',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Spacer(),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        ' 4.9 (120 reviews)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Divider(height: 40),
                  Text(
                    'About this course',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.course.longDescription.isNotEmpty
                        ? widget.course.longDescription
                        : widget.course.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 30),
                  if (_quiz != null) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              quiz: _quiz!,
                              courseTitle: widget.course.title,
                            ),
                          ),
                        ).then((_) => _loadQuizAndProgress());
                      },
                      icon: Icon(Icons.quiz),
                      label: Text(
                        _userProgress != null ? 'Retake Quiz' : 'Take Quiz',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  if (_userProgress != null) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CertificateScreen(
                              course: widget.course,
                              studentName: "John Doe", // Placeholder
                              date: "Feb 28, 2026",
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.workspace_premium),
                      label: Text('View Certificate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Enrolled successfully!')),
                      );
                    },
                    child: Text('Enroll in Course'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.black,
      child: _isInitialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                _controller.value.isPlaying
                    ? SizedBox.shrink()
                    : IconButton(
                        icon: Icon(
                          Icons.play_circle_fill,
                          size: 64,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.play();
                          });
                        },
                      ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
