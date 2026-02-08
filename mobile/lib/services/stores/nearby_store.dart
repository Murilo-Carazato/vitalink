import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/models/nearby_model.dart';
import 'package:vitalink/services/repositories/api/blood_center_repository.dart';
import 'package:vitalink/services/models/page_model.dart';

class NearbyStore with ChangeNotifier {
  ValueNotifier<List<NearbyModel>> state = ValueNotifier<List<NearbyModel>>([]);
  ValueNotifier<Position?> userPosition = ValueNotifier<Position?>(null);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<String> erro = ValueNotifier<String>('');

  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  Future<void> syncNearbyBloodCenters({
    // Parametro mantido para retrocompatibilidade, mas ignorado na nova lógica
    List<BloodCenterModel>? bloodCentersFromApi, 
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _lastFetchTime != null &&
        state.value.isNotEmpty &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return;
    }

    isLoading.value = true;
    try {
      Position position = await determinePosition();
      userPosition.value = position;

      // Chama o repositório passando as coordenadas para buscar já filtrado do backend
      // Usamos uma lista temporária de paginação que não será usada na UI do mapa
      final pageNotifier = ValueNotifier<List<dynamic>>([]); // PageModel dinâmico ou ignore
      
      // Instancia o repositório diretamente (ideal seria injeção de dependência via construtor)
      // Como não tenho acesso fácil ao container aqui, instanciei. 
      // TODO: Injetar BloodRepository corretamente.
      final repository = BloodRepository();
      
      final result = await repository.index(
        false, // hasPagination = false para pegar a lista (o backend limita a 5 se tiver coords)
        ValueNotifier(1), // page 1
        '', // search empty
        ValueNotifier([]), // pages ignore
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 500, // 500km radius (ou ajuste conforme regra de negócio)
      );

      // Converte BloodCenterModel -> NearbyModel
      // O backend já retornou ordenado por distância.
      // E esperamos que o backend tenha retornado o campo 'distance' no JSON, 
      // mas o BloodCenterModel talvez não tenha esse campo mapeado.
      // Se não tiver, calculamos a distância aqui apenas para preencher o model, 
      // mas sem fazer a filtragem pesada.
      
      List<NearbyModel> nearby = [];
      for (var bc in result) {
         // Se o backend enviar 'distance', poderíamos usar.
         // Por segurança, calculamos aqui rapidinho (são poucos itens agora, ~5).
         double dist = calcDistance(position, bc);
         nearby.add(NearbyModel(distance: dist, bloodCenter: bc));
      }

      state.value = nearby;
      _lastFetchTime = DateTime.now();
    } on Exception catch (e) {
      erro.value = e.toString();
      print('Erro ao buscar hemocentros próximos: $e');
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

  Future<List<NearbyModel>> getNearbyBCs(Position userPosition, List<BloodCenterModel> bloodCenters, {double radio = 20000}) async {
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