import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oral Detection Device',
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
        ).copyWith(
          secondary: Colors.blue,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CameraHistoryPage(),
    );
  }
}

class CameraHistoryPage extends StatefulWidget {
  @override
  _CameraHistoryPageState createState() => _CameraHistoryPageState();
}

class _CameraHistoryPageState extends State<CameraHistoryPage> {
  late List<File> _capturedImages; // List to store captured images
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _capturedImages = [];
  }

  //test
  void _capturePicture() {
    setState(() {
      final newImage = File('/home/riofrio/Flutter-codelab/namer_app/Captures');
      _capturedImages.add(newImage);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Transform.translate(
          offset: Offset(-30, 0),
          child: SvgPicture.asset(
            'assets/images/O.D.D..svg',
            height: 150,
          ),
        ),
      ),
      body: Row(
        children: [
          if (screenWidth >= 600)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.camera),
                  label: Text('Capture'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text('History'),
                ),
              ],
            ),
          Expanded(
            child: _selectedIndex == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _capturePicture,
                          child: Text("Capture Picture"),
                        ),
                      ],
                    ),
                  )
                : _capturedImages.isEmpty
                    ? Center(child: Text("No history"))
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // Number of columns
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: _capturedImages.length,
                        itemBuilder: (context, index) {
                          final image = _capturedImages[index];
                          return GestureDetector(
                            onTap: () {
                              print("Tapped on image $index");
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              child: image.existsSync()
                                  ? Image.file(image, fit: BoxFit.cover)
                                  : Image.asset(
                                      'assets/images/periodontal-disease.jpeg',
                                      fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: screenWidth < 600
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera),
                  label: 'Capture',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
              ],
            )
          : null,
    );
  }
}
