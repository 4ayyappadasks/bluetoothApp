import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../Controller/intialController/bluetoothcontroller.dart';
import '../widgets/service_tile.dart';
import '../widgets/characteristic_tile.dart';
import '../widgets/descriptor_tile.dart';

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeviceController(device));

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(device.platformName)),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isConnecting.value
                ? controller.disconnectDevice
                : controller.connectDevice,
            child: Text(controller.isConnecting.value ? "Disconnect" : "Connect"),
          )),
        ],
      ),
      body: Obx(() => ListView(
        children: <Widget>[
          Text('Device is ${controller.connectionState.value}'),
          ListTile(
            title: Text("RSSI: ${controller.rssi.value ?? 'N/A'} dBm"),
            subtitle: Text('MTU Size: ${controller.mtuSize.value ?? 'Unknown'} bytes'),
            trailing: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: controller.discoverServices,
            ),
          ),
          if (controller.isDiscoveringServices.value)
            Center(child: CircularProgressIndicator())
          else
            ...controller.services.map((service) {
              final characteristicTiles = service.characteristics.map((characteristic) {
                final descriptorTiles = characteristic.descriptors
                    .map((descriptor) => DescriptorTile(descriptor: descriptor))
                    .toList();

                return CharacteristicTile(
                  characteristic: characteristic,
                  descriptorTiles: descriptorTiles,
                );
              }).toList();

              return ServiceTile(
                service: service,
                characteristicTiles: characteristicTiles,
              );
            }).toList(),
        ],
      )),
    );
  }
}
