import 'package:flutter/material.dart';
import 'blogs_page.dart'; // for Blog model (use correct import path)

class BlogDetailsPage extends StatelessWidget {
  final Blog blog;

  const BlogDetailsPage({
    super.key,
    required this.blog,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blog Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blog Title
            Text(
              blog.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Date & time
            Text(
              "Posted on ${blog.createdAt.toLocal()}".split('.')[0],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 20),

            // Description / Content
            Text(
              blog.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
