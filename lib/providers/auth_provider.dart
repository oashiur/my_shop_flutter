import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  var _idToken = '';
  var _expiresInSec = DateTime.now();
  var _userId = '';
  Timer? _authTimer;

  bool get isAuth {
    return token.isNotEmpty;
  }

  String get token {
    if (_idToken.isNotEmpty && _expiresInSec.isAfter(DateTime.now())) {
      return _idToken;
    }
    return '';
  }

  String get userId {
    if (_userId.isNotEmpty && _expiresInSec.isAfter(DateTime.now())) {
      return _userId;
    }
    return '';
  }

  Future<void> authentication(
      {required String email,
      required String password,
      required bool isLogin}) async {
    const login = 'YOUR AUTHENTICATION LOGIN URL';
    const singup = 'YOUR AUTHENTICATION SINGUP URL';
    const key = 'API KEY';
    Uri url;

    if (isLogin) {
      url = Uri.parse(login + key);
    } else {
      url = Uri.parse(singup + key);
    }

    try {
      var response = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      var responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        _idToken = responseData['idToken'];
        _expiresInSec = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
        _userId = responseData['localId'];

        notifyListeners();

        final sPref = await SharedPreferences.getInstance();
        await sPref.setString('idToken', _idToken);
        await sPref.setString('expiresInSec', _expiresInSec.toIso8601String());
        await sPref.setString('userId', _userId);

        autoLogOut();
      } else {
        throw HttpExtention(message: responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    _idToken = '';
    _expiresInSec = DateTime.now();
    _userId = '';
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final sPref = await SharedPreferences.getInstance();
    sPref.clear();
  }

  void autoLogOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final seconds = _expiresInSec.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: seconds), logOut);
  }

  Future<void> isLogin() async {
    final sPref = await SharedPreferences.getInstance();

    if (!sPref.containsKey('idToken')) {
      return;
    }

    _idToken = sPref.getString('idToken')!;
    _expiresInSec = DateTime.parse(sPref.getString('expiresInSec')!);
    if (_expiresInSec.isBefore(DateTime.now())) {
      return;
    }
    _userId = sPref.getString('userId')!;
    notifyListeners();
    autoLogOut();
  }
}
