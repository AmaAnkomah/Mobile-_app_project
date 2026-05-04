import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class AddReviewModal extends StatefulWidget {
  final String courseId;
  final VoidCallback onReviewSubmitted;

  const AddReviewModal({
    Key? key,
    required this.courseId,
    required this.onReviewSubmitted,
  }) : super(key: key);

  @override
  _AddReviewModalState createState() => _AddReviewModalState();
}

class _AddReviewModalState extends State<AddReviewModal> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  final ApiService _api = ApiService();

  Future<void> _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    
    if (auth.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to review.')),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String name = user?.displayName ?? '';
    if (name.isEmpty && user?.email != null) {
      name = user!.email!.split('@')[0];
    }
    if (name.isEmpty) name = 'Anonymous';

    final review = Review(
      id: '', // Firestore will auto-generate or we use doc id
      courseId: widget.courseId,
      userId: auth.userId!,
      userName: name,
      rating: _rating.toDouble(),
      comment: _commentController.text.trim(),
      timestamp: Timestamp.now(),
    );

    await _api.addReview(review);

    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onReviewSubmitted();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding for keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write a Review',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about this course...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Review',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
