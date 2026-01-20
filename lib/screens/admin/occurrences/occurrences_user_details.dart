import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../home/components/custom_app_bar.dart';

class OccurrencesUserDetails extends StatefulWidget {
  final UserModel user;
  const OccurrencesUserDetails({super.key, required this.user});

  @override
  State<OccurrencesUserDetails> createState() => _OccurrencesUserDetailsState();
} 

// place a simple message "Under construction" in the center of the screen
class _OccurrencesUserDetailsState extends State<OccurrencesUserDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Detalhes de Ocorrências"),
      body: const Center(
        child: Text("Under construction"),
      ),    
    );
  }
}

