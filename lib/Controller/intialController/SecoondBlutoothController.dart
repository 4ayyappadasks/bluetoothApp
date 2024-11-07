import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class SecondBluetoothController extends GetxController {
  var adapterState = BluetoothAdapterState.unknown.obs;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  @override
  void onInit() {
    super.onInit();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      adapterState.value = state;
    });
  }

  @override
  void onClose() {
    _adapterStateSubscription.cancel();
    super.onClose();
  }
}
