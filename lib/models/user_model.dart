class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String? jobTitle;
  final DateTime? hireDate;
  final bool isAdmin;
  final bool onVacation;
  final int workload;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.workload,
    required this.hireDate,
    this.jobTitle,
    this.isAdmin = false,
    this.onVacation = false,
  });

  // Este é o método que "limpa" o JSON que você viu no terminal
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? 'Sem Nome',
      email: json['email'],
      password: json['password_hash'] ?? '',
      jobTitle: json['job_title'],
      isAdmin: json['is_admin'] ?? false,
      onVacation: json['is_on_vacation'] ?? false,
      workload: (json['workload'] as int?) ?? 40,
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'])
          : null, // Converte a string para DateTime
    );
  }
}