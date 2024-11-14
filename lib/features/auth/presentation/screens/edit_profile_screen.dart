import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                // Add other fields as needed
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user != null) {
                        try {
                          final response =
                              await Supabase.instance.client.auth.updateUser(
                            UserAttributes(
                              data: {'full_name': _fullNameController.text},
                              email: _emailController.text,
                            ),
                          );
                          if (response.user != null) {
                            _scaffoldKey.currentState!.showSnackBar(
                              const SnackBar(content: Text('Profile updated')),
                            );
                            Navigator.pop(context);
                          } else {
                            _scaffoldKey.currentState!.showSnackBar(
                              const SnackBar(content: Text('Update failed')),
                            );
                          }
                        } catch (e) {
                          _scaffoldKey.currentState!.showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      } else {
                        _scaffoldKey.currentState!.showSnackBar(
                          const SnackBar(content: Text('Not authenticated')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
