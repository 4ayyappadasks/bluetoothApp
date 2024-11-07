import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/intialController/ScanController.dart';
import '../utils/snackbar.dart';
import 'device_screen.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';

class ScanScreen extends StatelessWidget {
  ScanScreen({Key? key}) : super(key: key);

  final ScanController controller = Get.put(ScanController());

  Widget buildScanButton(BuildContext context) {
    return Obx(() {
      return FloatingActionButton(
        child: Icon(controller.isScanning.value ? Icons.stop : Icons.search),
        onPressed: controller.isScanning.value ? controller.onStopPressed : controller.onScanPressed,
        backgroundColor: controller.isScanning.value ? Colors.red : Colors.blue,
      );
    });
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return controller.systemDevices
        .map(
          (d) => SystemDeviceTile(
        device: d,
        onOpen: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DeviceScreen(device: d),
            settings: RouteSettings(name: '/DeviceScreen'),
          ),
        ),
        onConnect: () => controller.onScanPressed(),
      ),
    )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return controller.scanResults
        .map(
          (r) => ScanResultTile(
        result: r,
        onTap: () {
          controller.onScanPressed();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DeviceScreen(device: r.device),
              settings: RouteSettings(name: '/DeviceScreen'),
            ),
          );
        },
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Devices'),
        ),
        body: RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: Obx(() {
            return ListView(
              children: <Widget>[
                ..._buildSystemDeviceTiles(context),
                ..._buildScanResultTiles(context),
              ],
            );
          }),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
