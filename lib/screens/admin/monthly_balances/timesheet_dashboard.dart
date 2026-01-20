import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import 'timesheet_user_details.dart'; 
import '../../home/components/custom_app_bar.dart';

class TimesheetDashboard extends StatefulWidget {
  const TimesheetDashboard({super.key});

  @override
  State<TimesheetDashboard> createState() => _TimesheetDashboardState();
}

class _TimesheetDashboardState extends State<TimesheetDashboard> {
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
      // Usando sua CustomAppBar já com Logout fixo
      appBar: const CustomAppBar(title: "Gestão de Colaboradores"),
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
                    builder: (context) => TimesheetUserDetails(user: collaborator),
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