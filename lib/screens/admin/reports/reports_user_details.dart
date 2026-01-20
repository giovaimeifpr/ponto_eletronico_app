import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../home/components/custom_app_bar.dart';

class ReportsUserDetails extends StatefulWidget {
  final UserModel user;
  const ReportsUserDetails({super.key, required this.user});

  @override
  State<ReportsUserDetails> createState() => _ReportsUserDetailsState();
} 

// place a simple message "Under construction" in the center of the screen
class _ReportsUserDetailsState extends State<ReportsUserDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Detalhes de Relatórios"),
      body: const Center(
        child: Text("Under construction"),
      ),    
    );
  }
}

