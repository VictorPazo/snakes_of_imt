import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  int selectedIndex = 1;

  final Color primaryGreen =
  const Color(0x99115F15);

  void onItemTapped(int index) {

    switch (index) {

    // ⚙️ CONFIGURAÇÕES
      case 0:

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) =>
            const ConfigurationPage(),
          ),
        );

        break;

    // 📸 CAMERA
      case 3:

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (context) =>
            const CameraPage(),
          ),
        );

        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: primaryGreen,

      body: Column(

        children: [

          const SizedBox(height: 80),

          // 🔝 LOGO + NOME
          Column(

            children: [

              CircleAvatar(

                radius: 40,

                backgroundColor: Colors.white,

                child: ClipOval(

                  child: Image.asset(

                    'assets/logo.png',

                    width: 70,
                    height: 70,

                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(

                "SerPython",

                style: TextStyle(

                  color: Colors.white,

                  fontSize: 28,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 🐍 CARD CENTRAL
          Expanded(

            child: Center(

              child: GestureDetector(

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                      const CameraPage(),
                    ),
                  );
                },

                child: Container(

                  width:
                  MediaQuery.of(context)
                      .size
                      .width * 0.8,

                  height: 200,

                  decoration: BoxDecoration(

                    color:
                    const Color(0xFF115F15),

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Column(

                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [

                      const Icon(

                        Icons.camera_alt,

                        color: Colors.white,

                        size: 40,
                      ),

                      const SizedBox(height: 10),

                      Text(

                        "identify_snake".tr(),

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 18,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(

                        "tap_take_photo".tr(),

                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),

      // 🔻 NAVBAR
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: selectedIndex,

        onTap: onItemTapped,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.black,

        unselectedItemColor: Colors.black54,

        items: [

          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: "settings".tr(),
          ),

          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: "home".tr(),
          ),

          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: "history".tr(),
          ),

          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: "camera".tr(),
          ),
        ],
      ),
    );
  }
}