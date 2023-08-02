import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESCANNER',
      home: AnimatedSplashScreen(
        splash: Image.asset('assets/scanner.gif'), // Replace 'your_logo.gif' with your animated logo file
        nextScreen: HomeScreen(), // Replace HomeScreen() with the main screen of your app
        splashTransition: SplashTransition.fadeTransition,
        duration: 3000, // Duration in milliseconds for how long the splash screen should be shown
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _barcodeController = TextEditingController();
  String _scannedValue = '';

  @override
  void initState() {
    super.initState();
    _barcodeController.text = _scannedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Ticket Scanner'),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16), // Add left and right padding here
              child: TextFormField(
                controller: _barcodeController,
                onChanged: (value) {
                  setState(() {
                    _scannedValue = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Scanned Barcode',
                ),
                autofocus: true, // Keyboard will open automatically
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.red,
                  shape: CircleBorder(),
                  elevation: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _scannedValue = '';
                        _barcodeController.text = '';
                      });
                    },
                    customBorder: CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.restore,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Material(
                  color: Colors.blue,
                  shape: CircleBorder(),
                  elevation: 8,
                  child: InkWell(
                    onTap: () async {
                      String barcode = await FlutterBarcodeScanner.scanBarcode(
                        '#ff6666', // Color for the scan button background
                        'Cancel', // Text for the cancel button
                        true, // Use flash
                        ScanMode.BARCODE, // Scan mode (BARCODE or QR)
                      );

                      setState(() {
                        _scannedValue = barcode;
                        _barcodeController.text = barcode;
                      });

                      // Handle the scanned barcode here (e.g., print it)
                      print('Scanned barcode: $barcode');
                    },
                    customBorder: CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Material(
                  color: Colors.green, // Updated to greenish color
                  shape: CircleBorder(),
                  elevation: 8,
                  child: InkWell(
                    onTap: () {
                      // Implement your verification function here
                    },
                    customBorder: CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.verified_user,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
