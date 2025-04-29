import 'package:flutter/material.dart';
import 'service_details_screen.dart'; // New screen for detailed description

class ServicesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      "title": "Sustainable weed removal",
      "image": "assets/Picture.jpg",
      "price": 32.00,
      "oldPrice": 52.00,
      "description": "Offers: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris tellus porttitor purus, et volutpat sit.",
    },
    {
      "title": "Soil analysis and nutrient mapping",
      "image": "assets/Picture.jpg",
      "price": 26.00,
      "oldPrice": 52.00,
      "description": "Offers: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris tellus porttitor purus, et volutpat sit.",
    },
    {
      "title": "Crop Health Monitoring",
      "image": "assets/Picture.jpg",
      "price": 26.00,
      "oldPrice": 52.00,
      "description": "Offers: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris tellus porttitor purus, et volutpat sit.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop Agribot Services"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Navigate to details page on click
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceDetailsScreen(service: services[index]),
                  ),
                );
              },
              child: ServiceCard(service: services[index]),
            );
          },
        ),
      ),
    );
  }
}

// Card for each service
class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  const ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
            child: Image.asset(service["image"], width: 120, height: 120, fit: BoxFit.cover),
          ),
          SizedBox(width: 10),

          // Service Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service["title"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text("\$${service["price"]}", style: TextStyle(fontSize: 16, color: Colors.green[700])),
                      SizedBox(width: 5),
                      Text("\$${service["oldPrice"]}", style: TextStyle(fontSize: 14, color: Colors.red, decoration: TextDecoration.lineThrough)),
                      SizedBox(width: 5),
                      Text("-50%", style: TextStyle(fontSize: 14, color: Colors.red)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(service["description"], style: TextStyle(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),

          // Icons
          Column(
            children: [
              IconButton(icon: Icon(Icons.shopping_cart, color: Colors.green[700]), onPressed: () {}),
              IconButton(icon: Icon(Icons.favorite_border, color: Colors.green[700]), onPressed: () {}),
              IconButton(icon: Icon(Icons.search, color: Colors.green[700]), onPressed: () {}),
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
