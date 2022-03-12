import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  static const routeName = '/auth-screen';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repassController = TextEditingController();
  final _form = GlobalKey<FormState>();

  Widget myTextField({
    required String label,
    TextEditingController? controller,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
          label: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white60),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        validator: validator,
        onFieldSubmitted: (_) => _form.currentState!.validate(),
      ),
    );
  }

  Widget displayMood({required String title, required FontWeight fontWeight}) {
    return Text(
      title,
      style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontFamily: 'Raleway',
          fontWeight: fontWeight),
    );
  }

  Widget dot() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }

  void onFormSubmit() async {
    final _auth = Provider.of<AuthProvider>(context, listen: false);
    if (_form.currentState!.validate()) {
      if (_isLogin) {
        try {
          await _auth.authentication(
              email: _emailController.text,
              password: _passwordController.text,
              isLogin: true);
        } catch (error) {
          dialogBox(error.toString());
        }
      } else {
        try {
          _auth.authentication(
              email: _emailController.text,
              password: _passwordController.text,
              isLogin: false);
        } catch (error) {
          dialogBox(error.toString());
        }
      }
    }
  }

  void dialogBox(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Authentication Failed!'),
        content: Text(error.split(':')[0]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 5),
            child: ElevatedButton(
              onPressed: (() => Navigator.of(ctx).pop()),
              child: const Text('Okay'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceHeight = mediaQuery.size.height - mediaQuery.padding.top;
    final deviceWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 37, 72),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(deviceWidth > 400 ? 30 : 15),
            height: deviceHeight,
            width: deviceWidth,
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'MY SHOP',
                    style: TextStyle(
                        fontFamily: 'BlackOpsOne',
                        fontSize: 35,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 60,
                    width: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (!_isLogin) dot(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = false;
                                  _form.currentState!.reset();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _repassController.clear();
                                });
                              },
                              child: displayMood(
                                title: 'Register',
                                fontWeight: _isLogin
                                    ? FontWeight.normal
                                    : FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            '|',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                        Row(
                          children: [
                            if (_isLogin) dot(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = true;
                                  _form.currentState!.reset();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _repassController.clear();
                                });
                              },
                              child: displayMood(
                                title: 'Login',
                                fontWeight: _isLogin
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  myTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value!)) {
                          return null;
                        } else {
                          return 'please enter a valid email';
                        }
                      }),
                  myTextField(
                      label: 'Password',
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.length < 6 &&
                            RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                .hasMatch(value)) {
                          return null;
                        } else {
                          return 'upper case, lowercase, numeric, special character';
                        }
                      }),
                  if (!_isLogin)
                    myTextField(
                        controller: _repassController,
                        label: 'Confirm Password',
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (_passwordController.text ==
                              _repassController.text) {
                            return null;
                          } else {
                            return 'password don\'t match';
                          }
                        }),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLogin ? onFormSubmit : onFormSubmit,
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        textStyle: const TextStyle(
                            fontSize: 20, fontFamily: 'Raleway'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 15,
                        )),
                    child: Text(_isLogin ? 'Login' : 'Register'),
                  ),
                  const SizedBox(height: 15),
                  if (_isLogin)
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forget Password?',
                        style:
                            TextStyle(color: Colors.white60, letterSpacing: 1),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
