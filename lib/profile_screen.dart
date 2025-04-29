import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String userName = "Ziad Sameh";
  final String profilePicUrl =
      "https://img.freepik.com/vector-gratis/circulo-azul-usuario-blanco_78370-4707.jpg?t=st=1742213435~exp=1742217035~hmac=4155b532f1de0393c6f2742fcd3f2da794328bc9c2cbb34a1b7e16b37b955d81&w=740"; // Placeholder image

  final List<Map<String, String>> farms = [
    {
      "location": "Sakha / Kafr El-Sheikh",
      "crop": "Tomato",
    },
    {
      "location": "Alexandria",
      "crop": "Tomato",
    },
  ];

  final List<Map<String, String>> services = [
    {
      "type": "Sustainable weed removal",
      "farm": "Sakha",
      "date": "10 Mar 2025",
      "status": "Pending",
    },
    {
      "type": "Pest Control",
      "farm": "Alexandria",
      "date": "5 Apr 2025",
      "status": "Completed",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profilePicUrl),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Farms Section
            Text(
              "My Farms",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 100, // Reduced height since we're not showing images
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: farms.length,
                itemBuilder: (context, index) {
                  return FarmCard(farm: farms[index]);
                },
              ),
            ),

            SizedBox(height: 10),

            // Add New Farm Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFarmScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Add New Farm"),
              ),
            ),

            SizedBox(height: 20),

            // Tasks Section
            Text(
              "My Tasks",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children:
                  services
                      .map((service) => ServiceCard(service: service))
                      .toList(),
            ),

            SizedBox(height: 10),

            // Add New Task Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddTaskScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Add New Task"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Farm Card without image
class FarmCard extends StatelessWidget {
  final Map<String, String> farm;
  const FarmCard({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grass, color: Colors.green, size: 28),
              SizedBox(height: 8),
              Text(
                farm["location"]!,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                farm["crop"]!,
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for displaying service details
class ServiceCard extends StatelessWidget {
  final Map<String, String> service;
  const ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(Icons.agriculture, color: Colors.green),
        title: Text(service["type"]!),
        subtitle: Text("Farm: ${service["farm"]!}\nDate: ${service["date"]!}"),
        trailing: Text(
          service["status"]!,
          style: TextStyle(
            color:
                service["status"] == "Pending" ? Colors.orange : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Screen for adding a new farm
class AddFarmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Farm")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "Farm Name")),
            TextField(decoration: InputDecoration(labelText: "Location")),
            TextField(decoration: InputDecoration(labelText: "Crops")),
            TextField(
              decoration: InputDecoration(labelText: "Number of Lines"),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Line Length (m)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Add Farm"),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen for adding a new task
class AddTaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Task")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "Task Name")),
            TextField(decoration: InputDecoration(labelText: "Farm")),
            TextField(decoration: InputDecoration(labelText: "Packages")),
            TextField(decoration: InputDecoration(labelText: "Date")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }
}