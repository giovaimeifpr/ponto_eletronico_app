import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import 'reports_user_details.dart'; 
import '../../home/components/custom_app_bar.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({super.key});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userService.getAllUsers();
  }
 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Dashboard de Relatórios"),
       body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_,_) => const Divider(),
            itemBuilder: (context, index) {
              final collaborator = users[index];
              return ListTile(
                leading: CircleAvatar(child: Text(collaborator.fullName[0])),
                title: Text(collaborator.fullName),
                subtitle: Text(collaborator.jobTitle ?? 'Colaborador'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportsUserDetails(user: collaborator),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}