import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For API calls

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'CRUD Example',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: UserListScreen(),
//     );
//   }
// }

// Data Model
class User {
  final String id;
  final String name;
  final String position;
  final double salary;
  User({
    required this.id,
    required this.name,
    required this.position,
    required this.salary,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      position: json['position'],
      salary: double.parse(json['salary']),
    );
  }
}

// Main Screen to List Items
class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    const url =
        'http://192.168.162.1:3000/api/users'; // Replace with your API URL
    try {
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json; charset=UTF-8',
        'User-Agent': 'Flutter-App',
      };
      final response = await http
          .get(Uri.parse(url), headers: requestHeaders)
          .timeout(
            Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection timeout'),
          );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          users = data
              .map((item) => User.fromJson(item))
              .toList()
              .reversed
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load users: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteItem(String id) async {
    final url =
        'http://192.168.162.1:3000/api/users/$id'; // Replace with your API URL
    try {
      final response = await http
          .delete(Uri.parse(url))
          .timeout(
            Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection timeout'),
          );
      int statusCode = response.statusCode;
      debugPrint('Delete response status: $statusCode');
      // 204 No Content is success for DELETE, as is 200
      if (statusCode == 200 || statusCode == 204) {
        setState(() {
          users.removeWhere((user) => user.id == id);
        });
        debugPrint('User deleted successfully');
      } else {
        throw Exception('Failed to delete user: $statusCode');
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users List')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(
                    user.position + ' - \$${user.salary.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteItem(user.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditItemScreen(user: user),
                      ),
                    ).then((_) => fetchItems()); // Refresh list on return
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          ).then((_) => fetchItems()); // Refresh list on return
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Add Item Screen
class AddItemScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  Future<void> addItem(BuildContext context) async {
    const url =
        'http://192.168.162.1:3000/api/users'; // Replace with your API URL

    final requestBody = {
      'name': titleController.text,
      'position': positionController.text,
      'salary': double.tryParse(salaryController.text) ?? 0.0,
    };
    debugPrint('Sending request to: $url');
    debugPrint('Request body: ${json.encode(requestBody)}');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            body: json.encode(requestBody),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection timeout'),
          );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        throw Exception(
          'Failed to add item: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error adding item: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            TextField(
              controller: salaryController,
              decoration: InputDecoration(labelText: 'Salary'),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => addItem(context),
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

// Edit Item Screen
class EditItemScreen extends StatelessWidget {
  final User user;
  final TextEditingController titleController;
  final TextEditingController positionController;
  final TextEditingController salaryController;
  EditItemScreen({required this.user})
    : titleController = TextEditingController(text: user.name),
      positionController = TextEditingController(text: user.position),
      salaryController = TextEditingController(text: user.salary.toString());

  Future<void> updateItem(BuildContext context) async {
    final url = 'http://192.168.162.1:3000/api/users/${user.id}';

    final requestBody = {
      'name': titleController.text,
      'position': positionController.text,
      'salary': double.tryParse(salaryController.text) ?? 0.0,
    };
    debugPrint('Updating item at: $url');
    debugPrint('Request body: ${json.encode(requestBody)}');

    try {
      final response = await http
          .put(
            Uri.parse(url),
            body: json.encode(requestBody),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection timeout'),
          );
      debugPrint('Update response status: ${response.statusCode}');
      debugPrint('Update response body: ${response.body}');
      if (response.statusCode == 200) {
        debugPrint('Item updated successfully');
        Navigator.pop(context);
      } else {
        throw Exception(
          'Failed to update item: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error updating item: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            TextField(
              controller: salaryController,
              decoration: InputDecoration(labelText: 'Salary'),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => updateItem(context),
              child: Text('Update Item'),
            ),
          ],
        ),
      ),
    );
  }
}
