import 'package:flutter/material.dart';
import 'api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _errorMessage = '';

  // User profile data
  String userName = "";
  String userEmail = "";

  List<Map<String, String>> farms = [];
  List<Map<String, String>> services = [];
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadTasks();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Make sure we're using the correct endpoint
      final result = await AuthService.authenticatedRequest('user-profile');
      final farmsResult = await AuthService.authenticatedRequest('getFarms');

      print('Profile API response: $result');
      print('Farms API response: $farmsResult');

      if (result['success']) {
        final userData = result['data']['user'];
        final tasksData = result['data']['tasks'];

        setState(() {
          // Safely access user data with null checks
          userName = userData?['name']?.toString() ?? "Unknown User";
          userEmail = userData?['email']?.toString() ?? "";

          // Only use farms from getFarms endpoint
          farms = [];
          if (farmsResult['success'] == true &&
              farmsResult['data'] != null &&
              farmsResult['data']['data'] != null) {
            var farmsData = farmsResult['data']['data'];
            if (farmsData is List) {
              for (var farm in farmsData) {
                if (farm is Map) {
                  farms.add({
                    "id": farm['id']?.toString() ?? "",
                    "name": farm['name']?.toString() ?? "Unknown",
                    "location": farm['location']?.toString() ?? "Unknown",
                    "area": farm['area']?.toString() ?? "0",
                    "line_length": farm['line_length']?.toString() ?? "0",
                    "number_of_lines":
                        farm['number_of_lines']?.toString() ?? "0",
                    "notes": farm['notes']?.toString() ?? "",
                  });
                }
              }
            }
          }

          // Process tasks data if available
          services = [];
          if (tasksData != null) {
            if (tasksData is List) {
              for (var task in tasksData) {
                if (task is Map) {
                  services.add({
                    "type": task['type']?.toString() ?? "Unknown",
                    "farm": task['farm']?.toString() ?? "Unknown",
                    "date": task['date']?.toString() ?? "Unknown",
                    "status": task['status']?.toString() ?? "Pending",
                  });
                }
              }
            } else if (tasksData is Map) {
              services.add({
                "type": tasksData['type']?.toString() ?? "Unknown",
                "farm": tasksData['farm']?.toString() ?? "Unknown",
                "date": tasksData['date']?.toString() ?? "Unknown",
                "status": tasksData['status']?.toString() ?? "Pending",
              });
            }
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load profile';
          _isLoading = false;
        });

        // Check if token expired
        if (result['tokenExpired'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session expired. Please login again.')),
          );

          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          });
        }
      }
    } catch (e) {
      print('Profile loading error: $e');
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTasks() async {
    try {
      final response = await AuthService.authenticatedRequest('getTasks');
      print('Tasks API response: $response');

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['data'] != null) {
        List<dynamic> tasksList = response['data']['data'];
        setState(() {
          tasks =
              tasksList
                  .map(
                    (task) => {
                      'id': task['id'].toString(),
                      'title': task['title'].toString(),
                      'description': task['description'].toString(),
                      'status': task['status'].toString(),
                      'type': task['type'].toString(),
                      'farm_name': task['farms']['name'].toString(),
                      'price': task['price'].toString(),
                      'created_at': task['created_at'].toString(),
                    },
                  )
                  .toList();
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: Colors.green[700],
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(_errorMessage),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _loadUserProfile, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

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
                  Text(
                    userName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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
            Container(
              constraints: BoxConstraints(minHeight: 150, maxHeight: 250),
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
                  ).then(
                    (_) => _loadUserProfile(),
                  ); // Refresh data when returning
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Add New Farm"),
              ),
            ),

            SizedBox(height: 20),

            // Tasks Section
            Text(
              "Active Tasks",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            tasks.isEmpty
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No active tasks",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
                : Column(
                  children: tasks.map((task) => _buildTaskCard(task)).toList(),
                ),

            SizedBox(height: 10),

            // Add New Task Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskScreen(farms: farms),
                    ),
                  ).then(
                    (_) => _loadUserProfile(),
                  ); // Refresh data when returning
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

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        task['status'] == 'pending'
                            ? Colors.orange
                            : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task['status'].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Farm: ${task['farm_name']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              'Type: ${task['type'].toUpperCase()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              'Price: \$${task['price']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(task['description'], style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// Farm Card with updated design
class FarmCard extends StatelessWidget {
  final Map<String, String> farm;
  const FarmCard({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grass, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    farm["name"]!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, farm["location"]!),
            SizedBox(height: 8),
            _buildInfoRow(Icons.square_foot, "${farm["area"]!} m²"),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.straighten,
              "Lines: ${farm["number_of_lines"]!} × ${farm["line_length"]!}m",
            ),
            if (farm["notes"]?.isNotEmpty ?? false) ...[
              SizedBox(height: 8),
              Text(
                farm["notes"]!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
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
class AddFarmScreen extends StatefulWidget {
  @override
  _AddFarmScreenState createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _lineLengthController = TextEditingController();
  final _numberOfLinesController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _addFarm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await AuthService.authenticatedRequest(
        'addFarm',
        method: 'POST',
        body: {
          'name': _nameController.text,
          'location': _locationController.text,
          'area': double.parse(_areaController.text),
          'line_length': double.parse(_lineLengthController.text),
          'number_of_lines': int.parse(_numberOfLinesController.text),
          'crop_id': 1, // Always tomato
          'notes': _notesController.text,
        },
      );

      if (response['success']) {
        Navigator.pop(context); // Return to profile screen
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to add farm';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Farm"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Farm Name"),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter farm name'
                            : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location"),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter location' : null,
              ),
              TextFormField(
                controller: _areaController,
                decoration: InputDecoration(
                  labelText: "Area (in square meters)",
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter area' : null,
              ),
              TextFormField(
                controller: _lineLengthController,
                decoration: InputDecoration(
                  labelText: "Line Length (in meters)",
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter line length'
                            : null,
              ),
              TextFormField(
                controller: _numberOfLinesController,
                decoration: InputDecoration(labelText: "Number of Lines"),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter number of lines'
                            : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: "Notes"),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _addFarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Add Farm"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _lineLengthController.dispose();
    _numberOfLinesController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

// Screen for adding a new task
class AddTaskScreen extends StatefulWidget {
  final List<Map<String, String>> farms;

  const AddTaskScreen({Key? key, required this.farms}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedServiceId;
  int? _selectedFarmId;
  String? _selectedDate;

  List<Map<String, dynamic>> _availableDates = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('AddTaskScreen initState called');
    _loadDates();
  }

  Future<void> _loadDates() async {
    print('_loadDates called');
    try {
      // Get token for debugging
      final token = await AuthService.getToken();
      print(
        'Token for dates request: ${token != null ? 'Token exists' : 'No token found'}',
      );

      print('Making request to getDates endpoint');
      final response = await AuthService.authenticatedRequest('getDates');
      print('Raw API response: $response');

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['data'] != null) {
        print('Response has valid data');
        List<dynamic> datesList = response['data']['data'];
        print('Dates list from API: $datesList');

        setState(() {
          _availableDates =
              datesList.map((date) {
                print('Processing date: $date');
                return {
                  'id': date['id'].toString(),
                  'date': date['date'].toString(),
                  'formatted_date': date['date'].toString(),
                };
              }).toList();
          print('Final _availableDates: $_availableDates');
        });
      } else {
        print('Invalid response format or error: ${response['message']}');
      }
    } catch (e, stackTrace) {
      print('Error in _loadDates: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServiceId == null ||
        _selectedFarmId == null ||
        _selectedDate == null) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Validate all required fields are present and non-empty
      if (_titleController.text.isEmpty ||
          _descriptionController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all required fields';
          _isLoading = false;
        });
        return;
      }

      // Find the selected farm
      final selectedFarm = widget.farms.firstWhere(
        (farm) =>
            int.tryParse(farm['id']?.toString() ?? '0') == _selectedFarmId,
        orElse: () => widget.farms.first,
      );

      // Get the actual farm ID from the database
      final farmId = int.tryParse(selectedFarm['id']?.toString() ?? '0') ?? 0;

      // Prepare request body with all required fields
      final requestBody = {
        'service_id': _selectedServiceId.toString(),
        'farm_id': farmId.toString(),
        'date_id': _selectedDate,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'pending',
      };

      print('=== REQUEST DETAILS ===');
      print('Endpoint: addTask');
      print('Method: POST');
      print('Request Body:');
      print(requestBody);
      print('=====================');

      final response = await AuthService.authenticatedRequest(
        'addTask',
        method: 'POST',
        body: requestBody,
      );

      print('Add task response: $response');

      if (response['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task added successfully')));
        Navigator.pop(context);
      } else {
        final errorMsg = response['message'] ?? 'Failed to add task';
        print('Error adding task: $errorMsg');
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e, stackTrace) {
      print('Exception while adding task: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building AddTaskScreen with _availableDates: $_availableDates');
    return Scaffold(
      appBar: AppBar(
        title: Text("New Task"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service Type Selection
              DropdownButtonFormField<int>(
                value: _selectedServiceId,
                decoration: InputDecoration(
                  labelText: "Service Type",
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 1, child: Text("NPK")),
                  DropdownMenuItem(value: 2, child: Text("Weed")),
                  DropdownMenuItem(value: 3, child: Text("Disease")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedServiceId = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select a service type' : null,
              ),
              SizedBox(height: 16),

              // Farm Selection
              DropdownButtonFormField<int>(
                value: _selectedFarmId,
                decoration: InputDecoration(
                  labelText: "Select Farm",
                  border: OutlineInputBorder(),
                ),
                items:
                    widget.farms.map((farm) {
                      // Use the farm ID from the farm data
                      final farmId =
                          int.tryParse(farm['id']?.toString() ?? '0') ?? 0;
                      return DropdownMenuItem<int>(
                        value: farmId,
                        child: Text(farm["name"]!),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFarmId = value;
                  });
                },
                validator:
                    (value) => value == null ? 'Please select a farm' : null,
              ),
              SizedBox(height: 16),

              // Date Selection
              DropdownButtonFormField<String>(
                value: _selectedDate,
                decoration: InputDecoration(
                  labelText: "Select Date",
                  border: OutlineInputBorder(),
                ),
                items:
                    _availableDates.map((date) {
                      print('Creating dropdown item for date: $date');
                      return DropdownMenuItem<String>(
                        value: date['id'],
                        child: Text(date['date']),
                      );
                    }).toList(),
                onChanged: (value) {
                  print('Date selected: $value');
                  setState(() {
                    _selectedDate = value;
                  });
                },
                validator:
                    (value) => value == null ? 'Please select a date' : null,
              ),
              SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter a description'
                            : null,
              ),
              SizedBox(height: 20),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              ElevatedButton(
                onPressed: _isLoading ? null : _addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Add Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
