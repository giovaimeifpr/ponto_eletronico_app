import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';

class LocationService {
  
  // Função que verifica permissões e retorna a posição atual
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verifica se o GPS do celular está ligado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'O GPS está desativado. Por favor, ative-o.';
    }

    // 2. Verifica permissões de acesso
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permissão de localização negada.';
      }
    }

   // 3. Pega a posição usando as novas configurações (LocationSettings)
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, // Alta precisão para o ponto eletrônico
        distanceFilter: 10, // Só atualiza se o usuário se mover 10 metros
      ),
    );
  }
  // Função que calcula a distância entre o usuário e a empresa
  int calculateDistance(double userLat, double userLon) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLat, 
      userLon, 
      AppConstants.companyLatitude, 
      AppConstants.companyLongitude
    );
    return distanceInMeters.round(); // Retorna em metros inteiros
  }

  // Verifica se o usuário está dentro do raio permitido
  bool isWithinRange(int distance) {
    return distance <= AppConstants.allowedRadiusInMeters;
  }
}