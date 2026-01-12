class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String? jobTitle;
  final bool isAdmin;
  final int workload;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.workload,
    this.jobTitle,
    this.isAdmin = false,
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
      workload: (json['workload'] as int?) ?? 40,
    );
  }
}