import 'package:flutter/material.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailsScreen({required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service["title"]),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Image.asset(service["image"], width: 150, height: 150, fit: BoxFit.cover),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service["title"], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text("\$${service["price"]}", style: TextStyle(fontSize: 18, color: Colors.green[700])),
                            SizedBox(width: 5),
                            Text("\$${service["oldPrice"]}", style: TextStyle(fontSize: 16, color: Colors.red, decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(service["description"], style: TextStyle(color: Colors.grey[700])),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                              child: Text("Add To Cart"),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              icon: Icon(Icons.favorite_border, color: Colors.green[700]),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Description
            Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "Farmers face a wide range of challenges that can impact their yields and profitability. Here are some of the key issues they grapple with:\n\n"
              "Weeds:\nWeeds compete with plants for essential resources like sunlight, water, and nutrients, hindering their growth and reducing yields. They can also harbor pests and diseases.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
