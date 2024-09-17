import 'package:flutter/material.dart';
import 'package:pneumothoraxdashboard/models/menu_model.dart';

class BottomMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.person_2_rounded, title: 'Profile'),
    MenuModel(icon: Icons.logout, title: 'Logout'),
  ];
}
