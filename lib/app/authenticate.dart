import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:money_lover/app/expense_app.dart';

class LocalAuthenticatePage extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<LocalAuthenticatePage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Quét vân tay của bạn để xác thực',
          useErrorDialogs: true,
          stickyAuth: true);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _authorized =
      authenticated ? 'Authorized success' : 'Failed to authenticate';
      if (authenticated) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ExpenseApp()));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkBiometrics();
    _getAvailableBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Đăng nhập',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 42,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      Image.asset('assets/images/finger_print.png', width: 120,color: Colors.blue,),
                      Text('Xác thực vân tay',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Text('Xác thực bằng vân tay thay vì mật khẩu',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, height: 1.5))
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () => _authenticate(),
                    elevation: 0.0,
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      child: Text(
                        'Xác thực',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
