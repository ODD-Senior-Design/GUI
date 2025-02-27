import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  List<dynamic> _capturedImages = [];
  int _selectedIndex = 0;
  final String apiBaseUrl = "https://api.ranga-family.com";

  @override
  void initState() {
    super.initState();
    _capturedImages = [];
  }

  void _capturePicture() async {
    final String apiUrl = "$apiBaseUrl/generate/assessments?num=1";

    try {
      final url = Uri.parse(apiUrl);
      final response = await http.get(url, headers: {"Connection": "close"});
      print('API Response: ${response.body}');  // Log the entire response

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.isNotEmpty) {
          setState(() {
            _capturedImages.addAll(jsonResponse);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Image Captured Successfully!"))
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to capture image, Status: ${response.statusCode}")
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An Error occurred: $e"))
      );
    }
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
        toolbarHeight: 150,
        title: Transform.translate(
          offset: Offset(-30, 0),
          child: SvgPicture.asset(
            'assets/images/O.D.D..svg',
            height: 350,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Row(
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
                          Container(
                            margin: EdgeInsets.all(10),
                            width: 600,
                            height: 400,
                            color: Colors.grey,
                            child: Center(
                              child: Text(
                                "Live Feed",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _capturePicture,
                              child: Text("Capture Picture"),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _capturedImages.isEmpty
                      ? Center(child: Text("No history"))
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Number of columns
                            crossAxisSpacing: 5.0, // Downsize the container for images
                            mainAxisSpacing: 5.0,
                          ),
                          itemCount: _capturedImages.length,
                          itemBuilder: (context, index) {
                            final imageItem = _capturedImages[index];
                            final patient = imageItem['image']['image_set']?['patient'];
                            final imageUri = imageItem['image']['uri'];

                            if (patient == null || imageUri == null) {
                              return Center(child: Text("Invalid data received"));
                            }

                            return GestureDetector(
                              onTap: () {
                                print("Tapped on image $index");
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${patient['first_name']} ${patient['last_name']}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "ID: ${patient['id']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Image.network(
                                      imageUri,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    (loadingProgress.expectedTotalBytes ?? 1)
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading image: $error');
                                        return Center(
                                          child: Icon(Icons.error, color: Colors.red),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
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
