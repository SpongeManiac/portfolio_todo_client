import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/todo.dart';

class TodoAPI {
  String host;
  TodoAPI(this.host);

  Uri get todosUri {
    return Uri.parse('$host/todos/');
  }

  String jsonFormat = '?format=json';

  Future<List<Todo>> getTodos(BuildContext context) async {
    try {
      var uri = Uri.parse('$todosUri$jsonFormat');
      var response = await http.get(uri);
      Iterable listJson = json.decode(response.body);
      List<Todo> todos = List<Todo>.from(listJson.map((i) => Todo.fromJson(i)));
      return todos;
    } on http.ClientException catch (e) {
      print(e.message);
      print(e.uri);
      print(e.runtimeType);
    } catch (e) {
      print(e);
      print(e.runtimeType);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cannot reach server.'),
      ),
    );
    return [];
  }

  Future<bool> createTodo(Todo todo) async {
    try {
      var uri = Uri.parse('$todosUri');
      var response = await http.post(uri, body: todo.toJson());
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      //print(e);
      return false;
    }
  }

  Future<Todo> readTodo(int id) async {
    try {
      var uri = Uri.parse('$todosUri$id$jsonFormat');
      var response = await http.get(uri);
      Todo todo = json.decode(response.body);
      return todo;
    } catch (e) {
      return Todo.empty;
    }
  }

  Future<bool> updateTodo(Todo todo) async {
    try {
      var uri = Uri.parse('$todosUri${todo.id}');
      //print('Sending json: ${todo.toJson()}');
      var response = await http.put(uri, body: todo.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> delTodo(Todo todo) async {
    try {
      var uri = Uri.parse('$todosUri${todo.id}');
      var response = await http.delete(uri);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      //print(e);
      return false;
    }
  }
}
