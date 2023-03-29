

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireTime;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null ;
  }

  String? get token {
    if (_expireTime != null && _expireTime!.isAfter(DateTime.now()) && _token != null){
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> signUp(String email,String password) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBWLnBHDTYsEolbScYSZ1EL7H7mVn0JEfM');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email' : email,
          'password' : password, 
          'returnSecureToken':true
        })
      );
      final extractedData = json.decode(response.body);
      if (extractedData['error'] != null){
        throw HttpException(extractedData['error']['message']);
      }
      _token = extractedData['idToken'];
      _userId = extractedData['localId'];
      _expireTime = DateTime.now().add(
        Duration(
          seconds: int.parse(
            extractedData['expiresIn']
          )
        )
      );
      _autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({'token':_token,'userId': _userId, 'expiryTime': _expireTime?.toIso8601String()});
      prefs.setString('userData', userData);
    } catch (error)
    {
      throw error;
    }
  }

  Future<void> signIn(String email,String password) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBWLnBHDTYsEolbScYSZ1EL7H7mVn0JEfM');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email' : email,
          'password' : password, 
          'returnSecureToken':true
        })
      );
      final extractedData = json.decode(response.body);
      if (extractedData['error'] != null){
        throw HttpException(extractedData['error']['message']);
      }
      _token = extractedData['idToken'];
      _userId = extractedData['localId'];
      _expireTime = DateTime.now().add(
        Duration(
          seconds: int.parse(
            extractedData['expiresIn']
          )
        )
      );
      _autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({'token':_token,'userId': _userId, 'expiryDate': _expireTime?.toIso8601String()});
      prefs.setString('userData', userData);
    } catch (error)
    {
      throw error;
    }
  }

  Future<bool> autoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token = extractedUserData['token']  ;
    _userId = extractedUserData['userId'];
    _expireTime = expiryDate;
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> logOut() async{
    _token = null;
    _userId = null;
    _expireTime = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null ;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogOut() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpire = _expireTime?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire!),logOut);
  }

}