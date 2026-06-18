import 'dart:io';
import '../services/upload_service.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/services.dart';
import '../screens/screens.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() =>
      _CameraPageState();
}

class _CameraPageState
    extends State<CameraPage> {

  CameraController? _controller;

  late List<CameraDescription> cameras;

  final ImagePicker _picker =
  ImagePicker();

  final UploadService uploadService =
  UploadService();

  final IAService iaService =
  IAService();

  final SnakeInformationService
  snakeInformationService =
  SnakeInformationService();

  final Color primaryGreen =
  const Color(0x99115F15);

  @override
  void initState() {
    super.initState();

    initCamera();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      showTutorialPopup();
    });
  }

  //CAMERA
  Future<void> initCamera() async {

    cameras = await availableCameras();

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
    await applyFlashSetting();

    setState(() {});
  }

  Future<void> applyFlashSetting() async {

    if (_controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    final bool autoFlash =
        prefs.getBool('autoFlash') ?? false;

    try {
      await _controller!.setFlashMode(
        autoFlash
            ? FlashMode.always
            : FlashMode.off,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> showTutorialPopup() async {

    final prefs =
    await SharedPreferences.getInstance();

    bool naoMostrar =
        prefs.getBool(
          'naoMostrarTutorial',
        ) ??
            false;

    if (naoMostrar) return;

    bool checkValue = false;

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return StatefulBuilder(

          builder: (
              context,
              setState,
              ) {

            return Dialog(

              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),

              child: Container(

                padding:
                const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Column(

                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    Text(

                      "tutorial_title".tr(),

                      style:
                      const TextStyle(

                        fontSize: 22,

                        fontWeight:
                        FontWeight.bold,

                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(

                      "tutorial_text".tr(),

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Row(

                      children: [

                        Checkbox(

                          value: checkValue,

                          onChanged: (
                              value,
                              ) {

                            setState(() {

                              checkValue =
                              value!;
                            });
                          },
                        ),

                        Expanded(

                          child: Text(

                            "tutorial_never_show"
                                .tr(),

                            style:
                            const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton(

                      style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                        const Color(
                          0xFF115F15,
                        ),
                      ),

                      onPressed: () async {

                        if (checkValue) {

                          await prefs.setBool(

                            'naoMostrarTutorial',

                            true,
                          );
                        }

                        Navigator.pop(
                          context,
                        );
                      },

                      child: Text(

                        "close".tr(),

                        style:
                        const TextStyle(
                          color: Colors.white,
                        ),
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

  // 📸 CONFIRMAR FOTO
  Future<void> showConfirmDialog(
      String imagePath, {

        required bool isFromGallery,
      }) async {

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {

        return Dialog(

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          child: Container(

            padding:
            const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
              BorderRadius.circular(20),
            ),

            child: Column(

              mainAxisSize:
              MainAxisSize.min,

              children: [

                Text(

                  "confirm_title".tr(),

                  style:
                  const TextStyle(

                    fontSize: 22,

                    fontWeight:
                    FontWeight.bold,

                    color: Colors.black,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                ClipRRect(

                  borderRadius:
                  BorderRadius.circular(15),

                  child: Image.file(

                    File(imagePath),

                    height: 200,

                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // 🔥 CONFIRMAR
                ElevatedButton(

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(
                      0xFF115F15,
                    ),
                  ),

                  onPressed: () async {

                    final dialogNavigator =
                    Navigator.of(
                      dialogContext,
                    );

                    // 🔥 UPLOAD
                    final uploadResult =

                    await uploadService
                        .uploadImage(
                      File(imagePath),
                    );

                    dialogNavigator.pop();

                    if (!mounted) return;

                    if (uploadResult == null) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(

                        const SnackBar(

                          content: Text(
                            'Erro ao enviar imagem',
                          ),
                        ),
                      );

                      return;
                    }

                    // 🔥 IA
                    final prediction =

                    await iaService
                        .predictSnake(
                      File(imagePath),
                    );

                    if (!mounted) return;

                    if (prediction == null) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(

                        const SnackBar(

                          content: Text(
                            'Erro na identificação da IA',
                          ),
                        ),
                      );

                      return;
                    }

                    final snakeId =
                    prediction['snake_id'];

                    final confidence =
                    prediction['confidence'];

                    // 🔥 COBRA
                    final snake =

                    await snakeInformationService
                        .getSnakeById(
                      snakeId,
                    );

                    if (!mounted) return;

                    if (snake == null) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(

                        const SnackBar(

                          content: Text(
                            'Erro ao buscar cobra',
                          ),
                        ),
                      );

                      return;
                    }

                    // 🔥 USER
                    final user =

                        Supabase.instance.client
                            .auth.currentUser;

                    // 🔥 GPS
                    final position =

                    await Geolocator
                        .getCurrentPosition();

                    // 🔥 HISTÓRICO
                    try {

                      print("INSERTANDO...");

                      await Supabase.instance.client

                          .from('snake_historic')

                          .insert({

                        'profiles_id':
                        user!.id,

                        'snakes_id':
                        snake.id,

                        'image_url':
                        uploadResult.filePath,

                        'data_photo':
                        DateTime.now()
                            .toIso8601String(),

                        'latitude':
                        position.latitude,

                        'longitude':
                        position.longitude,
                      });

                      print("HISTORICO SALVO");

                    } catch (e) {

                      print("ERRO INSERT:");
                      print(e.toString());
                    }

                    // 🔥 INFO
                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            SnakeInformationScreen(

                              snake: snake,

                              confidence:
                              (confidence as num)
                                  .toDouble(),

                              imageUrl:
                              uploadResult.filePath,
                            ),
                      ),
                    );
                  },

                  child: Text(

                    isFromGallery

                        ? "confirm_new_photo".tr()

                        : "confirm_capture".tr(),

                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // 🔄 NOVA FOTO
                ElevatedButton(

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(
                      0xFF115F15,
                    ),
                  ),

                  onPressed: () {

                    Navigator.pop(
                      dialogContext,
                    );
                  },

                  child: Text(

                    isFromGallery

                        ? "choose_new_photo".tr()

                        : "new_capture".tr(),

                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📸 FOTO
  Future<void> takePhoto() async {

    if (_controller != null &&
        _controller!.value.isInitialized) {

      // 🔦 FLASH
      // Garante que o modo de flash esteja sincronizado com a
      // preferência salva antes de capturar, cobrindo o caso em
      // que o usuário mudou a configuração e voltou para a câmera
      // sem que a tela seja recriada.
      await applyFlashSetting();

      final image =
      await _controller!.takePicture();

      showConfirmDialog(

        image.path,

        isFromGallery: false,
      );
    }
  }

  // 🖼️ GALERIA
  Future<void> pickFromGallery() async {

    final XFile? image =

    await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      showConfirmDialog(

        image.path,

        isFromGallery: true,
      );
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

          // 📸 CAMERA
          Center(

            child:
            _controller == null ||

                !_controller!
                    .value
                    .isInitialized

                ? const CircularProgressIndicator(
              color: Colors.white,
            )

                : Container(

              width:
              MediaQuery.of(context)
                  .size
                  .width * 0.8,

              height:
              MediaQuery.of(context)
                  .size
                  .width * 0.8,

              decoration: BoxDecoration(

                borderRadius:
                BorderRadius.circular(
                  20,
                ),

                border: Border.all(

                  color: Colors.black,

                  width: 4,
                ),
              ),

              child: ClipRRect(

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

                child: CameraPreview(
                  _controller!,
                ),
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

                    backgroundColor:
                    Colors.white,

                    child: ClipOval(

                      child: Image.asset(

                        'assets/logo.png',

                        width: 50,
                        height: 50,

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    "camera_capture".tr(),

                    style:
                    const TextStyle(

                      color: Colors.white,

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔘 BOTÕES
          Positioned(

            bottom: 30,
            left: 0,
            right: 0,

            child: Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

              children: [

                // 🖼️ GALERIA
                IconButton(

                  icon: const Icon(

                    Icons.photo_library,

                    color: Colors.white,
                  ),

                  iconSize: 35,

                  onPressed:
                  pickFromGallery,
                ),

                // 📸 FOTO
                GestureDetector(

                  onTap: takePhoto,

                  child: Container(

                    width: 85,
                    height: 85,

                    decoration: BoxDecoration(

                      color: Colors.white,

                      shape: BoxShape.circle,

                      border: Border.all(

                        color: Colors.black,

                        width: 3,
                      ),
                    ),

                    child: const Icon(

                      Icons.camera_alt,

                      color: Color(
                        0xFF115F15,
                      ),

                      size: 35,
                    ),
                  ),
                ),

                IconButton(

                  icon: const Icon(

                    Icons.home,

                    color: Colors.white,
                  ),

                  iconSize: 35,

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
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