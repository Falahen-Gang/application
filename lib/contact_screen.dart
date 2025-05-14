import 'package:flutter/material.dart';
import 'api_service.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String userName = "";
  String userEmail = "";
  String userPhone = "";

  List<TeamMember> teamMembers = [
    TeamMember(
      name: "Member 1",
      email: "ziadsameh036@gmail.com",
      phone: "+201234567890",
      image: "assets/Picture.jpg",
      description: "Expert in Computer Architecture & ML.",
    ),
    TeamMember(
      name: "Member 2",
      email: "member2@example.com",
      phone: "+201234567891",
      image: "assets/Picture.jpg",
      description: "Specialist in Embedded Systems.",
    ),
    TeamMember(
      name: "Member 3",
      email: "member3@example.com",
      phone: "+201234567892",
      image: "assets/Picture.jpg",
      description: "AI Researcher.",
    ),
    TeamMember(
      name: "Member 4",
      email: "member4@example.com",
      phone: "+201234567893",
      image: "assets/Picture.jpg",
      description: "Robotics Enthusiast.",
    ),
    TeamMember(
      name: "Member 5",
      email: "member5@example.com",
      phone: "+201234567894",
      image: "assets/Picture.jpg",
      description: "VLSI & FPGA Engineer.",
    ),
    TeamMember(
      name: "Member 6",
      email: "member6@example.com",
      phone: "+201234567895",
      image: "assets/Picture.jpg",
      description: "Control Systems Developer.",
    ),
    TeamMember(
      name: "Member 7",
      email: "member7@example.com",
      phone: "+201234567896",
      image: "assets/Picture.jpg",
      description: "IoT & Smart Agriculture Specialist.",
    ),
    TeamMember(
      name: "Member 8",
      email: "member8@example.com",
      phone: "+201234567897",
      image: "assets/Picture.jpg",
      description: "Data Science & Big Data Expert.",
    ),
    TeamMember(
      name: "Member 9",
      email: "member9@example.com",
      phone: "+201234567898",
      image: "assets/Picture.jpg",
      description: "Cybersecurity Analyst.",
    ),
    TeamMember(
      name: "Member 10",
      email: "member10@example.com",
      phone: "+201234567899",
      image: "assets/Picture.jpg",
      description: "Digital Design Engineer.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await AuthService.authenticatedRequest('user-profile');
      if (result['success']) {
        final userData = result['data']['user'];
        setState(() {
          userName = userData?['name']?.toString() ?? "Unknown User";
          userEmail = userData?['email']?.toString() ?? "";
          userPhone = userData?['phone']?.toString() ?? "";
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await AuthService.authenticatedRequest(
        'sendmessage',
        method: 'POST',
        body: {
          'name': userName,
          'email': userEmail,
          'phone': userPhone,
          'message': _messageController.text.trim(),
        },
      );

      if (response['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Message sent successfully!')));
        _messageController.clear();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to send message';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMemberDetails(TeamMember member) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(member.image),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  member.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  member.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildContactInfo(Icons.email, member.email),
                      SizedBox(height: 8),
                      _buildContactInfo(Icons.phone, member.phone),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.green[700]),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.green[900], fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[50]!],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Information Section
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Send us a Message",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "We'll get back to you soon",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[900],
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildInfoRow(Icons.person, userName),
                              SizedBox(height: 8),
                              _buildInfoRow(Icons.email, userEmail),
                              SizedBox(height: 8),
                              _buildInfoRow(Icons.phone, userPhone),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Message Field
                      Text(
                        "Your Message",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type your message here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 5,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? "Please enter your message"
                                    : null,
                      ),
                      SizedBox(height: 24),

                      // Error Message
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(height: 24),

                      // Send Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    "Send Message",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),

                      // Team Section
                      SizedBox(height: 40),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Meet Our Team",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Our experts are here to help you",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 24),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                              itemCount: teamMembers.length,
                              itemBuilder: (context, index) {
                                TeamMember member = teamMembers[index];
                                return GestureDetector(
                                  onTap: () => _showMemberDetails(member),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green[50],
                                          ),
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundImage: AssetImage(
                                              member.image,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          member.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[900],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          member.description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class TeamMember {
  final String name;
  final String email;
  final String phone;
  final String image;
  final String description;

  TeamMember({
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.description,
  });
}
