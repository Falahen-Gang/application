import 'package:flutter/material.dart';
import 'api_service.dart';

/// ProfileScreen is the main screen that shows user information and their agricultural activities.
/// It displays:
/// - User's name and email
/// - List of farms owned by the user
/// - List of tasks assigned to the user
/// - Options to add new farms and tasks
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Shows a loading spinner when true, hides it when false
  bool _isLoading = true;

  // Stores any error messages that occur during data loading
  String _errorMessage = '';

  // Stores the user's basic information
  String userName = ""; // User's full name
  String userEmail = ""; // User's email address
  String userPhone = ""; // User's phone number

  // Lists to store different types of data
  List<Map<String, String>> farms = []; // List of all farms owned by the user
  List<Map<String, String>> services =
      []; // List of services available to the user
  List<Map<String, dynamic>> tasks = []; // List of tasks assigned to the user

  @override
  void initState() {
    super.initState();
    // When the screen first loads, fetch the user's profile and tasks
    _loadUserProfile();
    _loadTasks();
  }

  /// Loads the user's profile information from the server
  /// This includes:
  /// - User's name and email
  /// - List of farms
  /// - List of services
  /// If there's an error, it will show an error message
  Future<void> _loadUserProfile() async {
    try {
      // Make two API calls: one for user profile and one for farms
      final result = await AuthService.authenticatedRequest('user-profile');
      final farmsResult = await AuthService.authenticatedRequest('getFarms');

      // Print responses for debugging
      print('Profile API response: $result');
      print('Farms API response: $farmsResult');

      if (result['success']) {
        // Extract user data and tasks from the response
        final userData = result['data']['user'];
        final tasksData = result['data']['tasks'];

        setState(() {
          // Update user information with null safety checks
          // If any data is missing, use default values
          userName = userData?['name']?.toString() ?? "Unknown User";
          userEmail = userData?['email']?.toString() ?? "";
          userPhone = userData?['phone']?.toString() ?? "";

          // Clear existing farms list and add new farms from the API
          farms = [];
          if (farmsResult['success'] == true &&
              farmsResult['data'] != null &&
              farmsResult['data']['data'] != null) {
            var farmsData = farmsResult['data']['data'];
            if (farmsData is List) {
              // Process each farm in the list
              for (var farm in farmsData) {
                if (farm is Map) {
                  // Add farm with all its details
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
              // Process each task in the list
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
              // Handle single task case
              services.add({
                "type": tasksData['type']?.toString() ?? "Unknown",
                "farm": tasksData['farm']?.toString() ?? "Unknown",
                "date": tasksData['date']?.toString() ?? "Unknown",
                "status": tasksData['status']?.toString() ?? "Pending",
              });
            }
          }

          // Hide loading spinner
          _isLoading = false;
        });
      } else {
        // Handle error case
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load profile';
          _isLoading = false;
        });

        // Check if the error is due to expired token
        if (result['tokenExpired'] == true) {
          // Show message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session expired. Please login again.')),
          );

          // Wait 2 seconds then go to login screen
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          });
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      print('Profile loading error: $e');
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  /// Loads the user's tasks from the server
  /// This includes:
  /// - Task title and description
  /// - Task status (pending/completed)
  /// - Associated farm
  /// - Task type and price
  Future<void> _loadTasks() async {
    try {
      // Make API call to get tasks
      final response = await AuthService.authenticatedRequest('getTasks');
      print('Tasks API response: $response');

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['data'] != null) {
        // Get the list of tasks from the response
        List<dynamic> tasksList = response['data']['data'];
        setState(() {
          // Convert each task to a map with the required information
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
      // Handle any errors that occur while loading tasks
      print('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while data is being fetched
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green[700]),
              SizedBox(height: 16),
              Text(
                "Loading your profile...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Show error message if there's an error loading data
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
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(_errorMessage),
              SizedBox(height: 16),
              // Button to retry loading the profile
              ElevatedButton.icon(
                onPressed: _loadUserProfile,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Main profile screen layout
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
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
                    // User's name
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    // User's email
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 4),
                    // User's phone
                    Text(
                      userPhone,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Farms Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Farms",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddFarmScreen(),
                              ),
                            ).then((_) => _loadUserProfile());
                          },
                          icon: Icon(Icons.add, size: 18),
                          label: Text("Add Farm"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Horizontal scrollable list of farms
                    Container(
                      height: 220,
                      child:
                          farms.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.grass,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "No farms yet",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: farms.length,
                                itemBuilder: (context, index) {
                                  return FarmCard(farm: farms[index]);
                                },
                              ),
                    ),

                    SizedBox(height: 32),

                    // Tasks Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Active Tasks",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddTaskScreen(farms: farms),
                              ),
                            ).then((_) => _loadTasks());
                          },
                          icon: Icon(Icons.add, size: 18),
                          label: Text("Add Task"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Tasks List
                    tasks.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "No active tasks",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                        : Column(
                          children:
                              tasks
                                  .map((task) => _buildTaskCard(task))
                                  .toList(),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a card widget to display task information
  /// Shows:
  /// - Task title
  /// - Status (with color coding)
  /// - Farm name
  /// - Task type
  /// - Price
  /// - Description
  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Task title
                Expanded(
                  child: Text(
                    task['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        task['status'] == 'pending'
                            ? Colors.orange[100]
                            : Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task['status'].toUpperCase(),
                    style: TextStyle(
                      color:
                          task['status'] == 'pending'
                              ? Colors.orange[900]
                              : Colors.green[900],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Farm name
            Row(
              children: [
                Icon(Icons.grass, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  task['farm_name'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Task type and price
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  task['type'].toUpperCase(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Spacer(),
                Text(
                  '\$${task['price']}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Description
            Text(
              task['description'],
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}

/// FarmCard widget displays information about a single farm
/// Shows:
/// - Farm name
/// - Location
/// - Area
/// - Number of lines and line length
/// - Notes (if any)
class FarmCard extends StatelessWidget {
  final Map<String, String> farm;
  const FarmCard({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Farm name with icon
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.grass, color: Colors.green[700], size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    farm["name"]!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Location
            _buildInfoRow(Icons.location_on, farm["location"]!),
            SizedBox(height: 8),
            // Area
            _buildInfoRow(Icons.square_foot, "${farm["area"]!} m²"),
            SizedBox(height: 8),
            // Lines information
            _buildInfoRow(
              Icons.straighten,
              "Lines: ${farm["number_of_lines"]!} × ${farm["line_length"]!}m",
            ),
            // Notes (if any)
            if (farm["notes"]?.isNotEmpty ?? false) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        farm["notes"]!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates a row with an icon and text
  /// Used for displaying farm information consistently
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

/// ServiceCard widget displays information about a service
/// Shows:
/// - Service type
/// - Associated farm
/// - Date
/// - Status
class ServiceCard extends StatelessWidget {
  final Map<String, String> service;
  const ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.agriculture, color: Colors.green[700]),
        ),
        title: Text(
          service["type"]!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
        subtitle: Text(
          "Farm: ${service["farm"]!}\nDate: ${service["date"]!}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                service["status"] == "Pending"
                    ? Colors.orange[100]
                    : Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            service["status"]!,
            style: TextStyle(
              color:
                  service["status"] == "Pending"
                      ? Colors.orange[900]
                      : Colors.green[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// AddFarmScreen allows users to add a new farm
/// Collects:
/// - Farm name
/// - Location
/// - Area
/// - Line length
/// - Number of lines
/// - Notes
class AddFarmScreen extends StatefulWidget {
  @override
  _AddFarmScreenState createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for each form field
  final _nameController = TextEditingController(); // Farm name
  final _locationController = TextEditingController(); // Location
  final _areaController = TextEditingController(); // Area in square meters
  final _lineLengthController = TextEditingController(); // Length of each line
  final _numberOfLinesController = TextEditingController(); // Number of lines
  final _notesController = TextEditingController(); // Additional notes

  // State variables
  bool _isLoading = false; // Shows loading spinner when true
  String _errorMessage = ''; // Stores any error messages

  /// Handles the farm addition process
  /// Validates the form and sends data to the server
  Future<void> _addFarm() async {
    // Check if form is valid
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Send farm data to server
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
        // Return to profile screen on success
        Navigator.pop(context);
      } else {
        // Show error message if failed
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to add farm';
        });
      }
    } catch (e) {
      // Handle any errors
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
          child: Container(
            margin: EdgeInsets.only(top: 24),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Farm Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Farm Name",
                      prefixIcon: Icon(Icons.grass, color: Colors.green[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter farm name'
                                : null,
                  ),
                  SizedBox(height: 16),
                  // Location Field
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: "Location",
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter location'
                                : null,
                  ),
                  SizedBox(height: 16),
                  // Area Field
                  TextFormField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      labelText: "Area (in square meters)",
                      prefixIcon: Icon(
                        Icons.square_foot,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true ? 'Please enter area' : null,
                  ),
                  SizedBox(height: 16),
                  // Line Length Field
                  TextFormField(
                    controller: _lineLengthController,
                    decoration: InputDecoration(
                      labelText: "Line Length (in meters)",
                      prefixIcon: Icon(
                        Icons.straighten,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter line length'
                                : null,
                  ),
                  SizedBox(height: 16),
                  // Number of Lines Field
                  TextFormField(
                    controller: _numberOfLinesController,
                    decoration: InputDecoration(
                      labelText: "Number of Lines",
                      prefixIcon: Icon(
                        Icons.format_list_numbered,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter number of lines'
                                : null,
                  ),
                  SizedBox(height: 16),
                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: "Notes",
                      prefixIcon: Icon(Icons.note, color: Colors.green[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),
                  // Error Message Display
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
                  // Submit Button
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addFarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                "Add Farm",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _lineLengthController.dispose();
    _numberOfLinesController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

/// AddTaskScreen allows users to add a new task
/// Collects:
/// - Service type
/// - Farm selection
/// - Date
/// - Title
/// - Description
class AddTaskScreen extends StatefulWidget {
  final List<Map<String, String>> farms;

  const AddTaskScreen({Key? key, required this.farms}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _titleController = TextEditingController(); // Task title
  final _descriptionController = TextEditingController(); // Task description

  // Selected values for dropdowns
  int? _selectedServiceId; // Selected service type
  int? _selectedFarmId; // Selected farm
  String? _selectedDate; // Selected date

  // Available dates for task scheduling
  List<Map<String, dynamic>> _availableDates = [];

  // State variables
  bool _isLoading = false; // Shows loading spinner when true
  String _errorMessage = ''; // Stores any error messages

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  /// Loads available dates for task scheduling from the server
  Future<void> _loadDates() async {
    try {
      // Fetch available dates from server
      final response = await AuthService.authenticatedRequest('getDates');

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['data'] != null) {
        List<dynamic> datesList = response['data']['data'];
        setState(() {
          // Process dates into a list of maps
          _availableDates =
              datesList.map((date) {
                return {
                  'id': date['id'].toString(),
                  'date': date['date'].toString(),
                  'formatted_date': date['date'].toString(),
                };
              }).toList();
        });
      }
    } catch (e) {
      print('Error in _loadDates: $e');
    }
  }

  /// Handles the task addition process
  /// Validates the form and sends data to the server
  Future<void> _addTask() async {
    // Check if form is valid
    if (!_formKey.currentState!.validate()) return;
    // Check if all required fields are selected
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
      // Validate text fields
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

      // Get the farm ID
      final farmId = int.tryParse(selectedFarm['id']?.toString() ?? '0') ?? 0;

      // Prepare data for the server
      final requestBody = {
        'service_id': _selectedServiceId.toString(),
        'farm_id': farmId.toString(),
        'date_id': _selectedDate,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'pending',
      };

      // Send request to server
      final response = await AuthService.authenticatedRequest(
        'addTask',
        method: 'POST',
        body: requestBody,
      );

      if (response['success'] == true) {
        // Show success message and return to profile screen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task added successfully')));
        Navigator.pop(context);
      } else {
        // Show error message if failed
        final errorMsg = response['message'] ?? 'Failed to add task';
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      // Handle any errors
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
        title: Text("New Task"),
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
          child: Container(
            margin: EdgeInsets.only(top: 24),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Service Type Selection
                  DropdownButtonFormField<int>(
                    value: _selectedServiceId,
                    decoration: InputDecoration(
                      labelText: "Service Type",
                      prefixIcon: Icon(
                        Icons.category,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            value == null
                                ? 'Please select a service type'
                                : null,
                  ),
                  SizedBox(height: 16),

                  // Farm Selection
                  DropdownButtonFormField<int>(
                    value: _selectedFarmId,
                    decoration: InputDecoration(
                      labelText: "Select Farm",
                      prefixIcon: Icon(Icons.grass, color: Colors.green[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        widget.farms.map((farm) {
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
                        (value) =>
                            value == null ? 'Please select a farm' : null,
                  ),
                  SizedBox(height: 16),

                  // Date Selection
                  DropdownButtonFormField<String>(
                    value: _selectedDate,
                    decoration: InputDecoration(
                      labelText: "Select Date",
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        _availableDates.map((date) {
                          return DropdownMenuItem<String>(
                            value: date['id'],
                            child: Text(date['date']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDate = value;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Please select a date' : null,
                  ),
                  SizedBox(height: 16),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      prefixIcon: Icon(Icons.title, color: Colors.green[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter a title'
                                : null,
                  ),
                  SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: Icon(
                        Icons.description,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter a description'
                                : null,
                  ),
                  SizedBox(height: 24),

                  // Error Message Display
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

                  // Submit Button
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                "Add Task",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
