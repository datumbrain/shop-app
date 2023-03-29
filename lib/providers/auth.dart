import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireTime;
  String? _userId;

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
      notifyListeners();
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
      notifyListeners();
    } catch (error)
    {
      throw error;
    }
  }

}