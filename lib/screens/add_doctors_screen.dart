import 'package:flutter/material.dart';

class AddDoctorsScreen extends StatefulWidget {
  const AddDoctorsScreen({super.key});

  @override
  State<AddDoctorsScreen> createState() => _AddUsersScreenState();
}

class _AddUsersScreenState extends State<AddDoctorsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Add Doctors Screen'));
  }
}
