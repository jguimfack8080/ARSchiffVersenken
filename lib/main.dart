import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'createLobby.dart';
import 'lobby.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeasideAR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Lobby> lobbyList = []; // Liste des lobbies récupérée depuis le backend

  @override
  void initState() {
    super.initState();
    fetchLobbyList(); // Récupérer la liste des lobbies lors du chargement initial
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SeasideAR'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LobbyCreationPage(),
                ),
              ).then((value) {
                if (value != null && value) {
                  fetchLobbyList();
                }
              });
            },
            child: Text('Lobby erstellen'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lobbyList.length,
              itemBuilder: (context, index) {
                final lobby = lobbyList[index];
                return ListTile(
                  title: Text(
                    lobby.lobbyName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text('Users: ${lobby.users.join(", ")}'),
                  trailing: IconButton(
                    icon: Icon(Icons.login, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LobbyPage(lobbyName: lobby.lobbyName),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchLobbyList() async {
    final url =
        Uri.parse('http://195.37.49.59:8080/ar-23-backend/api/battleship/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> lobbyDataList = responseData as List<dynamic>;

      setState(() {
        lobbyList = lobbyDataList
            .map<Lobby>((lobbyData) => Lobby.fromJson(lobbyData))
            .toList();
      });
    } else {
      print(
          'Fehler beim Abrufen der Lobbyliste. Statuscode: ${response.statusCode}');
    }
  }
}
