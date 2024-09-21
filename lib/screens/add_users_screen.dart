import 'package:flutter/material.dart';

class AddUsersScreen extends StatefulWidget {
  const AddUsersScreen({super.key});

  @override
  State<AddUsersScreen> createState() => _AddUsersScreenState();
}

class _AddUsersScreenState extends State<AddUsersScreen> {
  bool _isEmailValid = true;
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: Container(
          width: screenSize.width,
          height: screenSize.height,
          padding: EdgeInsets.all(screenSize.width * 0.01),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email ID',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          setState(() {
                            _isEmailValid =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value);
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email ID is required';
                          } else if (!_isEmailValid) {
                            return 'Enter valid Email ID';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      ElevatedButton(
                        onPressed: () {
                          // Add user
                        },
                        child: const Text('Add User'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
