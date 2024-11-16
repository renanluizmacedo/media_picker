import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

final _picker = HLImagePicker();
List<HLPickerItem> _selectedImages = [];

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  Future<void> _openPicker() async {
    // Verificar e solicitar permissões
    if (await _requestPermissions()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final images = await _picker.openPicker();

        if (images.isNotEmpty) {
          setState(() {
            _selectedImages = images;
          });
        }
      } catch (e) {
        debugPrint('Erro ao abrir o picker: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao selecionar imagens.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissões negadas.')),
      );
    }
  }

Future<bool> _requestPermissions() async {
  final status = await Permission.camera.request();
  if (status.isDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permissão negada para a câmera.')),
    );
    return false;
  }
  return status.isGranted;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HL Image Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_selectedImages.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _selectedImages.map((image) {
                  final filePath = image.path; // Verifique o acesso ao caminho da imagem
                  return filePath != null
                      ? Image.file(
                          File(filePath),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : const Text('Imagem inválida.');
                }).toList(),
              )
            else
              const Text('Nenhuma imagem selecionada.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openPicker,
              child: const Text('Selecionar Imagens'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPicker,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
