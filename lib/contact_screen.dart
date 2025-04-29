import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

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

  void _showMemberDetails(TeamMember member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(member.image),
              ),
              SizedBox(height: 10),
              Text(
                member.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                member.email,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                member.phone,
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
              SizedBox(height: 10),
              Text(
                member.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact Us")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📌 **Contact Form**
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact Us",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: "Full Name"),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? "Please enter your name"
                                    : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: "Email"),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? "Please enter your email"
                                    : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(labelText: "Phone Number"),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? "Please enter your phone number"
                                    : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(labelText: "Message"),
                        maxLines: 4,
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? "Please enter your message"
                                    : null,
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Message Sent!")),
                              );
                              _nameController.clear();
                              _emailController.clear();
                              _phoneController.clear();
                              _messageController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Send Message"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// 📌 **Spacing Before Team Section**
            SizedBox(height: 30),

            /// 📌 **Meet Our Team Title**
            Text(
              "Meet Our Team",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            /// 📌 **Team Members Grid**
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two members per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // Square shape
              ),
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                TeamMember member = teamMembers[index];
                return GestureDetector(
                  onTap: () => _showMemberDetails(member),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            member.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          member.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}

/// **📌 Team Member Model**
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
