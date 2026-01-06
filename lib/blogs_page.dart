import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blog_details_page.dart';

class Blog {
  final String id;
  final String title;
  final String description;
  final String userId;
  final DateTime createdAt;

  Blog({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.createdAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final supabase = Supabase.instance.client;

  List<Blog> blogs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    final response = await supabase
        .from('blogs')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      blogs = response.map<Blog>((data) => Blog.fromJson(data)).toList();
      loading = false;
    });
  }

  Future<void> createBlog(String title, String description) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in.")),
      );
      return;
    }

    await supabase.from('blogs').insert({
      'title': title,
      'description': description,
      'user_id': userId,
    });

    Navigator.pop(context);
    fetchBlogs();
  }

  void openCreateBlogSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Create Blog",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  createBlog(
                    titleController.text.trim(),
                    descController.text.trim(),
                  );
                },
                child: Text("Post"),
              ),
              SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  Widget blogCard(BuildContext context, Blog blog) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => BlogDetailsPage(blog: blog),
          ),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.85),
              Colors.white.withOpacity(0.70),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              spreadRadius: 3,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Blog Title
            Text(
              blog.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 8),

            /// Blog Preview
            Text(
              blog.description.length > 180
                  ? blog.description.substring(0, 180) + "..."
                  : blog.description,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            SizedBox(height: 16),

            /// Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${blog.createdAt.toLocal()}".split('.')[0],
                    style: GoogleFonts.roboto(
                      fontSize: 12.5,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateBlogSheet,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, size: 28, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Waterfall Heading
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                "Blogs",
                style: GoogleFonts.waterfall(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),

            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: fetchBlogs,
                      child: blogs.isEmpty
                          ? Center(
                              child: Text(
                                "No blogs yet",
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(bottom: 100),
                              itemCount: blogs.length,
                              itemBuilder: (context, index) {
                                return blogCard(context, blogs[index]);
                                ;
                              },
                            ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
