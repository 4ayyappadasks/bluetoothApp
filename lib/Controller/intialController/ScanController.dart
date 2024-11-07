import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../../utils/snackbar.dart';

class ScanController extends GetxController {
  var systemDevices = <BluetoothDevice>[].obs;
  var scanResults = <ScanResult>[].obs;
  var isScanning = false.obs;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void onInit() {
    super.onInit();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      scanResults.value = results;
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      isScanning.value = state;
    });
  }

  @override
  void onClose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.onClose();
  }

  Future<void> onScanPressed() async {
    try {
      var withServices = [Guid("180f")];
      systemDevices.value = await FlutterBluePlus.systemDevices(withServices);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
    }
  }

  Future<void> onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
    }
  }

  Future<void> onRefresh() async {
    if (!isScanning.value) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
  }
}
