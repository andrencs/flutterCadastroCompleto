import 'dart:convert';

import 'package:cadastro_completo/data/dummy_users.dart';
import 'package:cadastro_completo/models/user.dart';
import 'package:cadastro_completo/sensitiveData/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  final Map<String, User> _items = {...DUMMY_USERS};

  List<User> get all {
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt(i);
  }

  Future<void> put(User user) async {
    if (user == null) {
      return;
    }

    if (user.id != null &&
        user.id.trim().isNotEmpty &&
        _items.containsKey(user.id)) {
      //alterar
      await http.patch(
        '$DB_LINK/users/${user.id}.json',
        body: json.encode(
          {
            'name': user.name,
            'email': user.email,
            'avatarURL': user.avatarURL,
          },
        ),
      );

      _items.update(user.id, (_) => user);
    } else {
      //adicionar
      final response = await http.post(
        '$DB_LINK/users.json',
        body: json.encode(
          {
            'name': user.name,
            'email': user.email,
            'avatarURL': user.avatarURL,
          },
        ),
      );

      final id = json.decode(response.body)['name'];

      _items.putIfAbsent(
        id,
        () => User(
          id: id,
          name: user.name,
          email: user.email,
          avatarURL: user.avatarURL,
        ),
      );
    }

    notifyListeners();
  }

  void remove(User user) {
    if (user != null && user.id != null) {
      _items.remove(user.id);
      notifyListeners();
    }
  }
}
