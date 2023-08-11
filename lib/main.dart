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
        splash: Image.asset('assets/scanner.gif'),
        nextScreen: LoginScreen(),
        splashTransition: SplashTransition.fadeTransition,
        duration: 3000,
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _userIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _loginMessage = '';

  Future<void> _performLogin() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://backup.zahid.com.bd/Junior/booth1/login.php';
    final response = await http.post(Uri.parse(url), body: {
      'user_id': _userIdController.text,
      'password': _passwordController.text,
    });

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final bool success = jsonData['success'];
      final String message = jsonData['message'];

      if (success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(_userIdController.text)));
      } else {
        setState(() {
          _loginMessage = message;
        });
      }
    } else {
      setState(() {
        _loginMessage = 'An error occurred. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _performLogin,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text(
                'Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Text(
              _loginMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen(this.userId);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _barcodeController = TextEditingController();
  String _scannedValue = '';
  int _currentIndex = 0;
  void _performLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _barcodeController.text = _scannedValue;
  }

  Future<void> _verifyBarcode() async {
    final url = 'https://backup.zahid.com.bd/Junior/booth1/check.php';

    try {
      final response = await http.post(Uri.parse(url), body: {
        'user_name': _scannedValue,
        'user_id': widget.userId,
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final bool status = jsonData['status'];
        final String message = jsonData['msg'];

        // Show the response message in an alert dialog
        showAlertDialog(status, message);

        // Clear the input field after showing the alert
        setState(() {
          _scannedValue = '';
          _barcodeController.clear();
        });
      } else {
        // Show an error alert if the HTTP request fails
        showAlertDialog(false, 'Failed to verify the barcode. Please try again later.');
      }
    } catch (e) {
      // Handle any exceptions or errors that occur during the request
      showAlertDialog(false, 'An error occurred during the request. Please check your network connection.');
    }
  }

  void showAlertDialog(bool status, String message) {
    Color alertColor;
    if (status) {
      alertColor = Colors.green;
    } else if (message == 'Already Entered') {
      alertColor = Colors.red;
    } else {
      alertColor = Colors.yellow;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status ? 'Success' : 'Failure'),
        content: Text(message),
        backgroundColor: alertColor,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
                        _barcodeController.clear();
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Handle logout action here
            _performLogout();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Entry List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout), // New logout icon
            label: 'Logout', // New logout label
          ),
        ],
      ),

    );
  }
}