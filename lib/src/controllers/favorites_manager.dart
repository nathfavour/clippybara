import 'package:get/get.dart';
import '../models/device_info.dart';

class FavoritesManager extends GetxController {
  final RxList<DeviceInfo> favorites = <DeviceInfo>[].obs;

  void addFavorite(DeviceInfo device) {
    if (!favorites.any((d) => d.id == device.id)) {
      favorites.add(device);
    }
  }

  void removeFavorite(String deviceId) {
    favorites.removeWhere((d) => d.id == deviceId);
  }
}
