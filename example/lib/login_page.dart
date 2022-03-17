import 'package:example/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rocket_chat_connector_flutter/rocket_chat_connector.dart'
    as rocket;
import 'constants.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _userController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  bool _loading = false;
  final _rocketHttpService = rocket.HttpService(Uri.parse(serverUrl));
  late rocket.AuthenticationService _rocketAuthService;

  @override
  void initState() {
    super.initState();
    _rocketAuthService = rocket.AuthenticationService(_rocketHttpService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  hintText: 'username/email',
                ),
              ),
              SizedBox(height: 6.0),
              TextField(
                controller: _passController,
                decoration: InputDecoration(
                  hintText: 'password',
                ),
              ),
              SizedBox(height: 6.0),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      _loading = true;
                    });

                    var _user = _userController.text.trim();
                    if (_user.isEmpty) {
                      _user = 'giaptt';
                    }
                    var _pass = _passController.text.trim();
                    if (_pass.isEmpty) {
                      _pass = '576173987';
                    }
                    final result = await _rocketAuthService.login(_user, _pass);
                    setState(() {
                      _loading = false;
                    });
                    if (result.status == 'success') {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  HomePage(authData: result)));
                    } else {
                      print('-- error');
                    }
                  },
                  child: Text('SignIn')),
              _loading ? CupertinoActivityIndicator() : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
