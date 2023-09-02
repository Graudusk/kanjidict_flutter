import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'character.dart';
import 'package:audioplayers/audioplayers.dart';

import 'widgets/kanjiLiteralQuestion.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<String> generateAudio(text, literal) async {
  var url = Uri.parse('http://localhost:8080/generateAudio');
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'text': text, 'literal': literal}),
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Request failed with status: ${response.statusCode}.');
  }
}

class _MyAppState extends State<MyApp> {
  Future<List<Character>>? futureCharacters;
  Character? correctCharacter;
  int score = 0;
  int correct = 0;
  int wrong = 0;
  bool loadingAudio = false;

  Future<List<Character>> fetchRandomCharacters() async {
    var url = Uri.parse('http://localhost:8080/fourRandomCharacters');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List<Character> characters = charactersFromJson(response.body);
      correctCharacter = characters[0];
      final List<Character> shuffledCharacters =
          charactersFromJson(response.body)..shuffle();

      return shuffledCharacters;
    } else {
      throw Exception('Request failed with status: ${response.statusCode}.');
    }
  }

  void playSound(text, literal) async {
    final player = AudioPlayer();
    setState(() {
      loadingAudio = true;
    });
    String audioUrl = await generateAudio(text, literal);

    await player.play(UrlSource('http://localhost:8080/${audioUrl}'));

    setState(() {
      loadingAudio = false;
    });
  }

  @override
  void initState() {
    super.initState();
    futureCharacters = fetchRandomCharacters();
  }

  void refresh() async {
    setState(() {
      futureCharacters = null;
    });
    futureCharacters = fetchRandomCharacters();
  }

  void onPressAnswer(e) {
    bool correctAnswer = e.literal == correctCharacter?.literal;
    if (correctAnswer) {
      setState(() {
        score++;
        correct++;
      });
    } else {
      setState(() {
        score--;
        wrong++;
      });
    }
    e.correct = correctAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<Character>>(
            future: futureCharacters,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData && correctCharacter != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Score: $score'),
                    OutlinedButton(
                      onPressed: refresh,
                      child: const Text('New kanji'),
                    ),
                    KanjiLiteralQuestion(
                        correctCharacter, snapshot.data, onPressAnswer)
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const Text('No data');
            },
          ),
        ),
      ),
    );
  }
}

MaterialStateProperty<Color> getBackgroundColor(correct) {
  return MaterialStateProperty.all(correct == null
      ? Colors.blue
      : correct == true
          ? Colors.green
          : Colors.red);
}

Widget kanjiMeaningQuestion(correctCharacter, answers, onPressAnswer) {
  return Column(
    children: [
      Text(
        correctCharacter!.meaning.join(', '),
        style: const TextStyle(fontSize: 24),
      ),
      ...answers!.map(
        (e) => Container(
          margin: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: [
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: getBackgroundColor(e.correct)),
                  onPressed: answers!.any((e) => e.correct == true) ||
                          e.correct == false
                      ? null
                      : () => {onPressAnswer(e)},
                  child: Column(
                    children: [
                      Text(
                        e.literal,
                        style:
                            const TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ],
                  )),
              Text(
                e!.reading.map((e) => e.t).join(', '),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// With Flutter, you create user interfaces by combining "widgets"
// You'll learn all about them (and much more) throughout this course!
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // Every custom widget must have a build() method
//   // It tells Flutter, which widgets make up your custom widget
//   // Again: You'll learn all about that throughout the course!
//   @override
//   Future<Widget> build(BuildContext context) async {
//     await fetchRandomCharacters();

//     // Below, a bunch of built-in widgets are used (provided by Flutter)
//     // They will be explained in the next sections
//     // In this course, you will, of course, not just use them a lot but
//     // also learn about many other widgets!
//     return MaterialApp(
//       title: 'Flutter First App',
//       theme: ThemeData(useMaterial3: true),
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Welcome to Flutter'),
//         ),
//         body: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           child: const Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 'Flutter - The Complete Guides',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               // SizedBox(height: 16),
//               // Text(
//               //   'Learn Flutter step-by-step, from the ground up.',
//               //   textAlign: TextAlign.center,
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
