import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/models/nearby_model.dart';

class NearbyStore with ChangeNotifier {
  ValueNotifier<List<NearbyModel>> state = ValueNotifier<List<NearbyModel>>([]);
  ValueNotifier<Position?> userPosition = ValueNotifier<Position?>(null);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<String> erro = ValueNotifier<String>('');

  Future<void> syncNearbyBloodCenters({required List<BloodCenterModel> bloodCentersFromApi}) async {
    isLoading.value = true;
    try {
      Position position = await determinePosition();
      List<NearbyModel> nearby = await getNearbyBCs(position, bloodCentersFromApi);

      userPosition.value = position;
      state.value = nearby;
    } on Exception catch (e) {
      erro.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Os serviços de localização estão desativados.');
    }

    permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }

//       8619
// D/permissions_handler( 8654): No permissions found in manifest for: []3
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissão de localização negada permanentemente. Por favor, habilite nas configurações do dispositivo.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<NearbyModel>> getNearbyBCs(Position userPosition, List<BloodCenterModel> bloodCenters, {double radio = 500}) async {
    List<NearbyModel> nearbyBCs = [];

    //Filtra os hemocentros dentro do raio especificado (por padrão é de 500km)
    List<BloodCenterModel> next = bloodCenters.where((element) {
      double distance = calcDistance(userPosition, element);
      return distance <= radio;
    }).toList();

    //Ordena os hemocentros pela distância
    next.sort((a, b) {
      double distanceA = calcDistance(userPosition, a);
      double distanceB = calcDistance(userPosition, b);
      return distanceA.compareTo(distanceB);
    });

    //Limita a lista aos 5 primeiros hemocentros
    List<BloodCenterModel> top5 = next.take(5).toList();

    //Constrói a lista de NearbyModel com os hemocentros e suas distâncias
    for (var bloodCenter in top5) {
      double distance = calcDistance(userPosition, bloodCenter);
      nearbyBCs.add(NearbyModel(
        distance: distance,
        bloodCenter: bloodCenter,
      ));
    }
    return nearbyBCs;
  }

  double calcDistance(Position userPosition, BloodCenterModel bloodCenter) {
    //Calcula a distância entre usuário e hemocentro
    return Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, bloodCenter.latitude, bloodCenter.longitude) / 1000; // Convertendo para quilômetros
  }
}