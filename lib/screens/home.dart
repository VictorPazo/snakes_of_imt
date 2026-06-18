import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int selectedIndex = 1;

  final Color primaryGreen =
  const Color(0x99115F15);

  GoogleMapController? mapController;

  LatLng currentPosition =
  const LatLng(-23.55052, -46.633308);

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    loadMap();
  }

  Future<void> loadMap() async {

    await getUserLocation();

    await loadSnakeMarkers();

    if (mapController != null) {

      await mapController!.animateCamera(

        CameraUpdate.newLatLngZoom(
          currentPosition,
          16,
        ),
      );
    }

    setState(() {});
  }

  Future<void> getUserLocation() async {

    bool serviceEnabled;

    LocationPermission permission;

    serviceEnabled =
    await Geolocator
        .isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission =
    await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
      await Geolocator.requestPermission();

      if (permission ==
          LocationPermission.denied) {
        return;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      return;
    }

    Position position =
    await Geolocator
        .getCurrentPosition();

    currentPosition = LatLng(
      position.latitude,
      position.longitude,
    );
  }

  Future<void> loadSnakeMarkers() async {

    try {

      final response =
      await Supabase.instance.client

          .from('snake_historic')

          .select('''
          *,
          snakes(*)
        ''');

      Set<Marker> loadedMarkers = {};

      loadedMarkers.add(

        Marker(

          markerId:
          const MarkerId("usuario"),

          position: currentPosition,

          infoWindow: InfoWindow(
            title: "Você está aqui",
          ),
        ),
      );

      for (var item in response) {

        if (item['latitude'] == null ||
            item['longitude'] == null) {
          continue;
        }

        final snake = item['snakes'];

        loadedMarkers.add(

          Marker(

            markerId:
            MarkerId(
              "snake_${item['id']}",
            ),

            position: LatLng(

              double.parse(
                item['latitude'].toString(),
              ),

              double.parse(
                item['longitude'].toString(),
              ),
            ),

            icon:
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),

            infoWindow: InfoWindow(

              title:
              snake['specie'],

              snippet:
              snake['poisonous'] == true

                  ? "Venenosa"
                  : "Não venenosa",
            ),
          ),
        );
      }

      setState(() {

        markers = loadedMarkers;
      });

    } catch (e) {

      debugPrint(
        "Erro markers: $e",
      );
    }
  }

  void onItemTapped(int index) {

    switch (index) {

      case 0:

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) =>
            const ConfigurationPage(),
          ),
        );

        break;

      case 2:

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) =>
            const HistoryPage(),
          ),
        ).then((_) {

          loadMap();
        });

        break;

      case 3:

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) =>
            const CameraPage(),
          ),
        ).then((_) {

          loadMap();
        });

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

          const SizedBox(height: 20),

          Expanded(

            child: Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: ClipRRect(

                borderRadius:
                BorderRadius.circular(20),

                child: GoogleMap(

                  initialCameraPosition:

                  CameraPosition(

                    target:
                    currentPosition,

                    zoom: 17,
                  ),

                  myLocationEnabled: true,

                  myLocationButtonEnabled: true,

                  zoomControlsEnabled: false,

                  markers: markers,

                  onMapCreated: (controller) {

                    mapController = controller;
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: GestureDetector(

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                    const CameraPage(),
                  ),
                ).then((_) {

                  loadMap();
                });
              },

              child: Container(

                width: double.infinity,

                height: 90,

                decoration: BoxDecoration(

                  color:
                  const Color(0xFF115F15),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    const Icon(

                      Icons.camera_alt,

                      color: Colors.white,

                      size: 35,
                    ),

                    const SizedBox(width: 12),

                    Text(

                      "identify_snake".tr(),

                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize: 20,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),

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