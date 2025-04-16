import 'package:flutter/material.dart';
import 'package:food/auth/backend_service.dart';
import 'package:logger/logger.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  String? _selectedImagePath;
  bool _isLoading = false;
  String? _role;
  String? _error;
  final _backendService = BackendService();
  final _logger = Logger();

  static const List<String> _availableImages = [
    'images/burger.jpg',
    'images/pizza.png',
    'images/cappucchino.png',
    'images/crab.png',
    'images/french_fry.png',
    'images/pasta.png',
    'images/rice_bowl1.png',
    'images/rice_bowl2.png',
    'images/watermelon_juice.png',
  ];

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final role = await _backendService.getUserRole();
      _logger.d('AddItemScreen fetched role: $role');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _role = role;
        if (role == null) {
          _error = 'Failed to fetch user role';
        } else if (role != 'Admin') {
          _error = 'Access restricted to admins';
        }
      });
      if (role != null && role != 'Admin' && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access restricted to admins')),
        );
      }
    } catch (e) {
      _logger.e('Role check error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error checking role: $e';
      });
    }
  }

  void _pickImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _availableImages.length,
            itemBuilder: (context, index) {
              final imagePath = _availableImages[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImagePath = imagePath;
                    _logger.d('Selected image: $imagePath');
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedImagePath == imagePath ? Colors.deepOrange : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      _logger.e('Error loading image: $imagePath');
                      return const Icon(Icons.error);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) {
      _logger.d('Form validation failed');
      return;
    }
    if (_selectedImagePath == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    String? error;
    try {
      _logger.d('Attempting to add item: $_name, price: $_price, image: $_selectedImagePath');
      error = await _backendService.addMenuItem(
        name: _name,
        price: _price,
        imagePath: _selectedImagePath!,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.e('Add item timed out after 10 seconds');
          return 'Operation timed out. Please try again.';
        },
      );
    } catch (e) {
      _logger.e('Add item exception: $e');
      error = 'Error adding item: $e';
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (error != null) {
      _logger.e('Add item error: $error');
      String errorMessage = error;
      if (error.contains('User not logged in')) {
        errorMessage = 'Please log in to add an item';
      } else if (error.contains('Failed to add item')) {
        errorMessage = 'Failed to add item. Please try again';
      } else if (error.contains('timed out')) {
        errorMessage = 'Request timed out. Check your connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } else {
      _logger.d('Item added successfully: $_name');
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Menu Item'),
          backgroundColor: Colors.deepOrange,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_role != 'Admin') {
      return const Scaffold(
        body: Center(child: Text('Access restricted')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: const Text(
          'Add Menu Item',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter item name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price (BDT)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null ? 'Enter valid price' : null,
                onSaved: (value) => _price = double.parse(value!),
              ),
              const SizedBox(height: 16),
              _selectedImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _selectedImagePath!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          _logger.e('Error loading image: $_selectedImagePath');
                          return const Icon(Icons.error);
                        },
                      ),
                    )
                  : Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.photo),
                label: const Text('Pick Image'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Item',
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
    );
  }
}