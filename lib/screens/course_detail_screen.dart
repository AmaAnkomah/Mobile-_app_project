import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'quiz_screen.dart';
import 'certificate_screen.dart';
import '../models/review.dart';
import '../widgets/add_review_modal.dart';
import 'package:intl/intl.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late YoutubePlayerController _controller;
  bool _isInitialized = false;
  Quiz? _quiz;
  Map<String, dynamic>? _userProgress;
  bool _isEnrolled = false;
  bool _isEnrolling = false;
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  final ApiService _api = ApiService();

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    double sum = 0;
    for (var r in _reviews) {
      sum += r.rating;
    }
    return sum / _reviews.length;
  }

  /// Extracts the YouTube video ID from any URL format:
  /// - https://www.youtube.com/watch?v=VIDEO_ID
  /// - https://youtu.be/VIDEO_ID
  /// - https://www.youtube.com/embed/VIDEO_ID
  String _extractVideoId(String url) {
    // youtu.be short links
    final shortRegex = RegExp(r'youtu\.be/([\w-]{11})');
    final shortMatch = shortRegex.firstMatch(url);
    if (shortMatch != null) return shortMatch.group(1)!;

    // embed links
    final embedRegex = RegExp(r'youtube\.com/embed/([\w-]{11})');
    final embedMatch = embedRegex.firstMatch(url);
    if (embedMatch != null) return embedMatch.group(1)!;

    // standard watch?v= links (also handles &t= and other params)
    final watchRegex = RegExp(r'[?&]v=([\w-]{11})');
    final watchMatch = watchRegex.firstMatch(url);
    if (watchMatch != null) return watchMatch.group(1)!;

    // Fallback: return a known-good public domain video
    debugPrint('Could not extract video ID from: \$url');
    return 'dQw4w9WgXcQ';
  }

  @override
  void initState() {
    super.initState();
    
    final videoId = _extractVideoId(widget.course.videoUrl);
    debugPrint('CourseDetailScreen: videoId = \$videoId from \${widget.course.videoUrl}');
    
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableJavaScript: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );
    
    setState(() {
      _isInitialized = true;
    });
    
    _loadQuizAndProgress();
  }

  Future<void> _loadQuizAndProgress() async {
    debugPrint("CourseDetailScreen: Starting _loadQuizAndProgress");
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    Quiz? quiz;
    Map<String, dynamic>? progress;
    bool enrolled = false;
    List<Review> fetchedReviews = [];

    // Fetch Quiz
    try {
      quiz = await _api.fetchQuiz(widget.course.id);
      debugPrint("CourseDetailScreen: fetched quiz: \${quiz?.id}");
    } catch (e) {
      debugPrint("CourseDetailScreen: Error fetching quiz: \$e");
    }

    // Fetch Progress
    try {
      progress = await _api.getUserProgress(
        auth.userId ?? '',
        widget.course.id,
      );
      debugPrint("CourseDetailScreen: fetched progress: \$progress");
    } catch (e) {
      debugPrint("CourseDetailScreen: Error fetching progress: \$e");
    }

    // Fetch Enrollment
    try {
      enrolled = await _checkEnrollment(auth.userId ?? '', widget.course.id);
      debugPrint("CourseDetailScreen: fetched enrolled: \$enrolled");
    } catch (e) {
      debugPrint("CourseDetailScreen: Error checking enrollment: \$e");
    }

    // Fetch Reviews
    try {
      fetchedReviews = await _api.fetchReviews(widget.course.id);
    } catch (e) {
      debugPrint("CourseDetailScreen: Error fetching reviews: \$e");
    }

    if (mounted) {
      setState(() {
        _quiz = quiz;
        _userProgress = progress;
        _isEnrolled = enrolled;
        _reviews = fetchedReviews;
        _isLoadingReviews = false;
      });
      debugPrint("CourseDetailScreen: UI updated. _quiz is \${_quiz != null ? 'NOT NULL' : 'NULL'}");
    }
  }

  Future<bool> _checkEnrollment(String userId, String courseId) async {
    // We could add a specific method to ApiService for this, but for now we can check via Firestore check.
    // Or just fetch all user enrollments.
    return await _api.isEnrolled(userId, courseId);
  }

  @override
  void dispose() {
    _controller.close();
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
                  ElevatedButton.icon(
                    onPressed: _quiz == null ? null : () {
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
                    icon: _quiz == null
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.quiz, size: 24),
                    label: Text(
                      _quiz == null
                          ? 'Loading Quiz...'
                          : (_userProgress != null ? 'Retake Quiz' : 'Take Quiz'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_userProgress != null) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final userEmail = auth.userEmail ?? 'Student';
                        final userName = userEmail.contains('@') ? userEmail.split('@')[0].toUpperCase() : userEmail;
                        
                        String formattedDate = DateFormat.yMMMd().format(DateTime.now());
                        if (_userProgress != null && _userProgress!['completed_at'] != null) {
                          try {
                            final date = _userProgress!['completed_at'].toDate();
                            formattedDate = DateFormat.yMMMd().format(date);
                          } catch (e) {
                            debugPrint("Error parsing date: $e");
                          }
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CertificateScreen(
                              course: widget.course,
                              studentName: userName,
                              date: formattedDate,
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
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
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
                      if (_userProgress != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
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
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.course.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'By Instructor',
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Expanded(
                        child: Text(
                          _isLoadingReviews ? ' ...' : ' ${_averageRating.toStringAsFixed(1)} (${_reviews.length} reviews)',
                          style: TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Student Reviews',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isEnrolled)
                        TextButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) => AddReviewModal(
                                courseId: widget.course.id,
                                onReviewSubmitted: () {
                                  _loadQuizAndProgress();
                                },
                              ),
                            );
                          },
                          icon: Icon(Icons.edit, size: 16),
                          label: Text('Write Review'),
                        ),
                    ],
                  ),
                  if (!_isEnrolled)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Enroll to leave a review.',
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ),
                  SizedBox(height: 12),
                  if (_isLoadingReviews)
                    Center(child: CircularProgressIndicator())
                  else if (_reviews.isEmpty)
                    Text('No reviews yet. Be the first to review!')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      review.userName.substring(0, 1).toUpperCase(),
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      review.userName,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < review.rating ? Icons.star : Icons.star_border,
                                        size: 14,
                                        color: Colors.amber,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              if (review.comment.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  review.comment,
                                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                                ),
                              ],
                              SizedBox(height: 6),
                              Text(
                                DateFormat.yMMMd().format(review.timestamp.toDate()),
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 80), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: _isEnrolled
              ? Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'ALREADY ENROLLED',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: _isEnrolling
                      ? null
                      : () async {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          if (auth.userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please login to enroll')),
                            );
                            return;
                          }

                          setState(() => _isEnrolling = true);
                          final res = await _api.enroll(
                            auth.userId!,
                            widget.course.id,
                          );

                          if (mounted) {
                            setState(() {
                              _isEnrolling = false;
                              if (res['success']) _isEnrolled = true;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res['success'] ? 'Enrolled successfully!' : 'Enrollment failed: ${res['error']}'),
                                backgroundColor: res['success'] ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isEnrolling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'ENROLL NOW',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return SafeArea(
      bottom: false, // keep bottom safe area for nav bar
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _isInitialized
              ? YoutubePlayer(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
