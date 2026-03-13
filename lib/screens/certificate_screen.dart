import 'package:flutter/material.dart';
import '../models/course.dart';

class CertificateScreen extends StatelessWidget {
  final Course course;
  final String studentName;
  final String date;

  const CertificateScreen({
    super.key,
    required this.course,
    required this.studentName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course Certificate')),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.amber[700]!, width: 4),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: 80, color: Colors.amber[700]),
              SizedBox(height: 20),
              Text(
                'CERTIFICATE OF COMPLETION',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              Divider(height: 40, thickness: 2, color: Colors.amber[100]),
              Text(
                'This is to certify that',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              ),
              SizedBox(height: 15),
              Text(
                studentName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              SizedBox(height: 15),
              Text(
                'has successfully completed the course',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                course.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Text(
                'Issued on: $date',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSignature('Instructor'),
                  _buildSignature('Platform Director'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Certificate downloaded successfully!'),
                    ),
                  );
                },
                icon: Icon(Icons.download),
                label: Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignature(String title) {
    return Column(
      children: [
        Container(
          width: 100,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
          ),
        ),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
