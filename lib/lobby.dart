import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class Lobby {
  final String lobbyName;
  final List<String> users;

  Lobby({
    required this.lobbyName,
    required this.users,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    return Lobby(
      lobbyName: json['lobbyName'] ?? '',
      users: List<String>.from(
          json['users']?.map((user) => user['userName']) ?? []),
    );
  }
}

class LobbyPage extends StatelessWidget {
  final String lobbyName;

  const LobbyPage({required this.lobbyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby: $lobbyName'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            joinLobby(context);
          },
          child: Text('Lobby beitreten'),
        ),
      ),
    );
  }

  Future<void> joinLobby(BuildContext context) async {
    final url = Uri.parse(
        'http://195.37.49.59:8080/ar-23-backend/api/battleship/enter');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'lobbyName': lobbyName,
      'appId': '0',
      'username': 'friday1',
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final socketURL = responseData['socketURL'];

      final channel = IOWebSocketChannel.connect(socketURL);
      channel.stream.listen((message) {
        print('Eingehende Nachricht: $message');
      });

      print('Erfolgreich der Lobby $lobbyName beigetreten.');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erfolgreich beigetreten'),
          content: Text('Sie sind der Lobby $lobbyName beigetreten.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print(
          'Fehler beim Beitreten der Lobby $lobbyName. Statuscode: ${response.statusCode}');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Fehler beim Beitreten'),
          content: Text(
              'Beim Beitreten zur Lobby $lobbyName ist ein Fehler aufgetreten.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
