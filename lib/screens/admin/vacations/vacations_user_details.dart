import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../components/layout/custom_app_bar.dart';

class VacationsUserDetails extends StatefulWidget {
  final UserModel user;
  const VacationsUserDetails({super.key, required this.user});

  @override
  State<VacationsUserDetails> createState() => _VacationsUserDetailsState();
}

class _VacationsUserDetailsState extends State<VacationsUserDetails> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Detalhes de Férias"),
      body: const Center(
        child: Text("Under construction"),
      ),    
    );
  }
}


