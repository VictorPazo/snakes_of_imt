import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  late List<CameraDescription> cameras;
  final ImagePicker _picker = ImagePicker();

  final Color primaryGreen = const Color(0x99115F15);

  @override
  void initState() {
    super.initState();
    initCamera();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showTutorialPopup();
    });
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
    setState(() {});
  }

  // 🔥 POPUP INICIAL
  Future<void> showTutorialPopup() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 DESCOMENTA SE QUISER RESETAR O POPUP PRA TESTE
    // await prefs.remove('naoMostrarTutorial');

    bool naoMostrar = prefs.getBool('naoMostrarTutorial') ?? false;
    if (naoMostrar) return;

    bool checkValue = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Modo de uso:",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "1. Capture em local iluminado.\n\n"
                          "2. Foto nítida.\n\n"
                          "3. Centralize a serpente.\n\n"
                          "4. Use galeria se quiser.\n\n"
                          "Mantenha distância segura!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(
                          value: checkValue,
                          onChanged: (value) {
                            setState(() {
                              checkValue = value!;
                            });
                          },
                        ),
                        const Text(
                          "Não mostrar novamente",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF115F15),
                      ),
                      onPressed: () async {
                        if (checkValue) {
                          await prefs.setBool('naoMostrarTutorial', true);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Fechar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 POPUP DE CONFIRMAÇÃO
  Future<void> showConfirmDialog(String imagePath, {required bool isFromGallery}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Deseja:",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(imagePath),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF115F15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    isFromGallery
                        ? "Confirmar nova foto"
                        : "Confirmar captura",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF115F15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    isFromGallery
                        ? "Escolher nova foto"
                        : "Realizar nova captura",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📸 CAMERA
  Future<void> takePhoto() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();
      showConfirmDialog(image.path, isFromGallery: false);
    }
  }

  // 🖼 GALERIA
  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      showConfirmDialog(image.path, isFromGallery: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: Stack(
        children: [

          // 📷 CAMERA
          Center(
            child: _controller == null || !_controller!.value.isInitialized
                ? const CircularProgressIndicator(color: Colors.white)
                : Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CameraPreview(_controller!),
              ),
            ),
          ),

          // 🔝 TOPO
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Realize a captura",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔻 BOTÕES
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  iconSize: 35,
                  onPressed: pickFromGallery,
                ),

                GestureDetector(
                  onTap: takePhoto,
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF115F15),
                      size: 35,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  iconSize: 35,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}