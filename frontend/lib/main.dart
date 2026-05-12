import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For API calls

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ItemListScreen(),
    );
  }
}

// Data Model
class Item {
  final String id;
  final String name;
  final double price;
  final String description;
  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      name: json['name'],
      price: double.parse(json['price']),
      description: json['description'],
    );
  }
}

// Main Screen to List Items
class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<Item> items = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    const url =
        'http://192.168.162.1:3000/api/products'; // Replace with your API URL
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
          items = data.map((item) => Item.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load items: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteItem(String id) async {
    final url =
        'http://192.168.162.1:3000/api/products/$id'; // Replace with your API URL
    try {
      final response = await http
          .delete(Uri.parse(url))
          .timeout(
            Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection timeout'),
          );
      debugPrint('Delete response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          items.removeWhere((item) => item.id == id);
        });
      } else {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Items List')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteItem(item.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditItemScreen(item: item),
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
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> addItem(BuildContext context) async {
    const url =
        'http://192.168.162.1:3000/api/products'; // Replace with your API URL

    final requestBody = {
      'name': titleController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'description': descriptionController.text,
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
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
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
  final Item item;
  final TextEditingController titleController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  EditItemScreen({required this.item})
    : titleController = TextEditingController(text: item.name),
      priceController = TextEditingController(text: item.price.toString()),
      descriptionController = TextEditingController(text: item.description);

  Future<void> updateItem(BuildContext context) async {
    final url = 'http://192.168.162.1:3000/api/products/${item.id}';

    final requestBody = {
      'name': titleController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'description': descriptionController.text,
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
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
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
