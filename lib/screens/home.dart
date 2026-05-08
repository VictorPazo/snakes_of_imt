import 'package:flutter/material.dart';
import 'camera.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 1;

  final Color primaryGreen = const Color(0x99115F15);

  void onItemTapped(int index) {
    switch (index) {
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CameraPage(),
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
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CameraPage(),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF115F15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Identificar serpente",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Toque para tirar uma foto",
                        style: TextStyle(color: Colors.white70),
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ""),
        ],
      ),
    );
  }
}