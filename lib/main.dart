import 'package:flutter/material.dart';
import 'package:flutter_sorteio_time/model/person.dart';
import 'package:flutter_sorteio_time/page/team_screen.dart';
import 'package:flutter_sorteio_time/provider/person_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PersonProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team BF4',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Soldados',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff202124),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('img/bf_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: const Color(0xff202124).withOpacity(0.8)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white)),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: const Color(0xff202124).withOpacity(0.8)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _scoreController,
                decoration: const InputDecoration(
                  labelText: 'Score',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final score = double.tryParse(_scoreController.text) ?? 0.0;
                if (name.isNotEmpty && score >= 0.0 && score <= 10.0) {
                  final person = Person(name: name, score: score);
                  Provider.of<PersonProvider>(context, listen: false)
                      .addPerson(person);
                  _nameController.clear();
                  _scoreController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff202124).withOpacity(0.7),
              ),
              child: const Text(
                'ADD SOLDIE',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: Consumer<PersonProvider>(
                builder: (context, personProvider, child) {
                  return ListView.builder(
                    itemCount: personProvider.persons.length,
                    itemBuilder: (context, index) {
                      final person = personProvider.persons[index];
                      final isSelected = personProvider.isSelected(person);
                      return Dismissible(
                        key: Key(person.name),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmação"),
                                content: Text(
                                    "Você realmente quer excluir ${person.name}?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("Excluir"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          personProvider.removePerson(person);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                          color: Colors.red,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 1),
                          width: MediaQuery.of(context).size.width,
                          color: const Color(0xff1a2027).withOpacity(0.7),
                          child: ListTile(
                            title: Text(
                              person.name,
                              style: const TextStyle(
                                  color: Color(0xffea8e04), fontSize: 18),
                            ),
                            subtitle: Text(
                              'Score: ${person.score}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xffea8e04),
                                  ),
                                  onPressed: () {
                                    _editScoreDialog(context, person);
                                  },
                                ),
                                Checkbox(
                                  activeColor: const Color(0xffea8e04),
                                  fillColor: MaterialStateProperty.resolveWith(
                                      (states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return null;
                                    }
                                    return Colors.black54;
                                  }),
                                  value: isSelected,
                                  onChanged: (value) {
                                    personProvider.selectPerson(person);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff202124).withOpacity(0.7),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TeamScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.autorenew,
          color: Color(0xffea8e04),
        ),
      ),
    );
  }

  void _editScoreDialog(BuildContext context, Person person) {
    final TextEditingController scoreController =
        TextEditingController(text: person.score.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Score'),
          content: TextField(
            controller: scoreController,
            decoration: const InputDecoration(labelText: 'Score'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newScore =
                    double.tryParse(scoreController.text) ?? person.score;
                if (newScore >= 0.0 && newScore <= 10.0) {
                  Provider.of<PersonProvider>(context, listen: false)
                      .updatePersonScore(person, newScore);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
