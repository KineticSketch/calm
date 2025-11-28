import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import '../providers/signin_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signInProvider = context.read<SignInProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // Data Management
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('导出数据 (分享)'),
            onTap: () async {
              final jsonString = signInProvider.exportData();
              final directory = await getTemporaryDirectory();
              final file = File('${directory.path}/signin_data.json');
              await file.writeAsString(jsonString);
              await Share.shareXFiles([XFile(file.path)], text: 'Sign-in Data');
            },
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('保存到文件'),
            onTap: () async {
              try {
                final jsonString = signInProvider.exportData();
                // Save to Downloads folder on Android
                final directory = Directory('/storage/emulated/0/Download');

                if (!await directory.exists()) {
                  // Fallback to app documents if Downloads not accessible
                  final appDir = await getApplicationDocumentsDirectory();
                  final timestamp = DateTime.now().millisecondsSinceEpoch;
                  final file = File(
                    '${appDir.path}/signin_data_$timestamp.json',
                  );
                  await file.writeAsString(jsonString);

                  if (context.mounted) {
                    toastification.show(
                      context: context,
                      title: const Text('保存成功'),
                      description: Text('已保存至: ${file.path}'),
                      type: ToastificationType.success,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                  }
                  return;
                }

                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final file = File(
                  '${directory.path}/signin_data_$timestamp.json',
                );
                await file.writeAsString(jsonString);

                if (context.mounted) {
                  toastification.show(
                    context: context,
                    title: const Text('保存成功'),
                    description: const Text('已保存至 Download 文件夹'),
                    type: ToastificationType.success,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  toastification.show(
                    context: context,
                    title: const Text('保存失败'),
                    description: Text(e.toString()),
                    type: ToastificationType.error,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('导入数据 (JSON)'),
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                File file = File(result.files.single.path!);
                String content = await file.readAsString();
                bool success = await signInProvider.importData(content);
                if (context.mounted) {
                  toastification.show(
                    context: context,
                    title: Text(success ? '导入成功' : '导入失败'),
                    type: success
                        ? ToastificationType.success
                        : ToastificationType.error,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('清除所有数据', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认清除?'),
                  content: const Text('此操作不可恢复。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        signInProvider.clearData();
                        Navigator.pop(context);
                        toastification.show(
                          context: context,
                          title: const Text('数据已清除'),
                          type: ToastificationType.info,
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                      },
                      child: const Text(
                        '清除',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // QR Code Transfer
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('二维码分享数据'),
            onTap: () {
              final data = signInProvider.exportData();
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: QrImageView(
                      data: data,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('扫描二维码导入'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScanScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class QRScanScreen extends StatelessWidget {
  const QRScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫描二维码')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              context.read<SignInProvider>().importData(barcode.rawValue!).then(
                (success) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    toastification.show(
                      context: context,
                      title: Text(success ? '导入成功' : '导入失败'),
                      type: success
                          ? ToastificationType.success
                          : ToastificationType.error,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                  }
                },
              );
              break; // Only process the first code
            }
          }
        },
      ),
    );
  }
}
