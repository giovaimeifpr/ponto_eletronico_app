class AppConstants {
  // Nomes das tabelas no Supabase
  static const String tableUsers = 'users';
  static const String tableTimeEntries = 'time_entries';
  static const String tableVacations = 'vacations';

  // Configurações de Geofencing (RN02)
  static const double allowedRadiusInMeters = 300.0; // Raio de 300 metros

  // Coordenadas da Empresa
  static const double companyLatitude = -25.435466588254563;
  static const double companyLongitude = -54.597499986948634;
  
  // Mensagens padrão
  static const String appName = 'Ponto Eletrônico';
}