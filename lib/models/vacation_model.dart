enum VacationStatus { pending, approved, rejected }

class VacationModel {
  final String id;
  final int periodIndex;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final VacationStatus status;
  final String? rejectionReason;

  VacationModel({
    required this.id,
    required this.periodIndex,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
    this.rejectionReason,
  });

  // O factory precisa estar DENTRO da classe
  factory VacationModel.fromJson(Map<String, dynamic> json) {
    VacationStatus parseStatus(String status) {
      switch (status.toLowerCase()) {
        case 'approved':
          return VacationStatus.approved;
        case 'rejected':
          return VacationStatus.rejected;
        default:
          return VacationStatus.pending;
      }
    }

    return VacationModel(
      id: json['id'] ?? '',
      periodIndex: json['period_index'] ?? 1,
      // Usamos parse para converter as strings DATE do banco em DateTime do Dart
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalDays: json['total_days'] ?? 0,
      status: parseStatus(json['status'] ?? 'pending'),
      rejectionReason: json['rejection_reason'],
    );
  }

  // Adicionei este método para facilitar o INSERT no banco depois
  Map<String, dynamic> toJson() {
    return {
      'period_index': periodIndex,
      'start_date': startDate.toIso8601String().split('T')[0], // Apenas a data YYYY-MM-DD
      'end_date': endDate.toIso8601String().split('T')[0],
      'total_days': totalDays,
      'status': status.name, // Salva como string: 'pending', etc.
    };
  }
}