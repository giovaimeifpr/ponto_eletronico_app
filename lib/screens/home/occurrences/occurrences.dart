import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../home/components/custom_app_bar.dart';

class Occurrences extends StatefulWidget {
  final UserModel user;
  const Occurrences({super.key, required this.user});

  @override
  State<Occurrences> createState() => _OccurrencesState();
}

class _OccurrencesState extends State<Occurrences> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Cadastro de Ocorrências"),
      body: const Center(
        child: Text("Under construction"),
      ),    
    );
  }
}


