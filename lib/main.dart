import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

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

  Future<void> _verifyBarcode() async {
    print('Scanned barcode: $_scannedValue'); // Debugging: Print the scanned barcode

    final url = 'https://backup.zahid.com.bd/Junior/booth1/check.php';
    final response = await http.post(Uri.parse(url), body: {'user_name': _scannedValue});

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final bool status = jsonData['status'];
      final String message = jsonData['msg'];

      print('Response status: $status'); // Debugging: Print the response status
      print('Response message: $message'); // Debugging: Print the response message

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(status ? 'Success' : 'Failure'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        ),
      );
    } else {
      print('Request failed with status: ${response.statusCode}'); // Debugging: Print the request status code

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to verify the barcode. Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        ),
      );
    }
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
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                autofocus: true,
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
                        '#ff6666',
                        'Cancel',
                        true,
                        ScanMode.BARCODE,
                      );

                      setState(() {
                        _scannedValue = barcode;
                        _barcodeController.text = barcode;
                      });

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
                  color: Colors.green,
                  shape: CircleBorder(),
                  elevation: 8,
                  child: InkWell(
                    onTap: _verifyBarcode,
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
