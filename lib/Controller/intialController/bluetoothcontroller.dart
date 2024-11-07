import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutterblutooth/utils/extra.dart';
import 'package:get/get.dart';
import '../../utils/snackbar.dart';

class DeviceController extends GetxController {
  final BluetoothDevice device;

  DeviceController(this.device);

  var connectionState = BluetoothConnectionState.disconnected.obs;
  var rssi = RxnInt();
  var mtuSize = RxnInt();
  var services = <BluetoothService>[].obs;
  var isDiscoveringServices = false.obs;
  var isConnecting = false.obs;
  var isDisconnecting = false.obs;

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<int> _mtuSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;

  @override
  void onInit() {
    super.onInit();
    _connectionStateSubscription = device.connectionState.listen((state) async {
      connectionState.value = state;
      if (state == BluetoothConnectionState.connected) {
        services.clear();
        rssi.value = await device.readRssi();
      }
    });

    _mtuSubscription = device.mtu.listen((mtu) => mtuSize.value = mtu);
    _isConnectingSubscription = device.isConnecting.listen((connecting) => isConnecting.value = connecting);
    _isDisconnectingSubscription = device.isDisconnecting.listen((disconnecting) => isDisconnecting.value = disconnecting);
  }

  @override
  void onClose() {
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.onClose();
  }

  Future<void> connectDevice() async {
    try {
      await device.connectAndUpdateStream();
      Snackbar.show(ABC.a, "Connect: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.a, "Connect Error: $e", success: false);
    }
  }

  Future<void> disconnectDevice() async {
    try {
      await device.disconnectAndUpdateStream();
      Snackbar.show(ABC.a, "Disconnect: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.a, "Disconnect Error: $e", success: false);
    }
  }

  Future<void> discoverServices() async {
    isDiscoveringServices.value = true;
    try {
      services.value = await device.discoverServices();
      Snackbar.show(ABC.a, "Discover Services: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.a, "Discover Services Error: $e", success: false);
    }
    isDiscoveringServices.value = false;
  }

  Future<void> requestMtu() async {
    try {
      await device.requestMtu(223);
      Snackbar.show(ABC.a, "Request Mtu: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.a, "Change Mtu Error: $e", success: false);
    }
  }
}
