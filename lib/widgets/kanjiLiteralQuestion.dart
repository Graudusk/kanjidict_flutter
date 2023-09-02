import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kanjidict_flutter/character.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class KanjiLiteralQuestion extends StatefulWidget {
  const KanjiLiteralQuestion(
      this.correctCharacter, this.answers, this.onPressAnswer,
      {super.key});

  final Character? correctCharacter;
  final dynamic answers;
  final Function onPressAnswer;

  @override
  State<KanjiLiteralQuestion> createState() => _KanjiLiteralQuestionState();
}

class _KanjiLiteralQuestionState extends State<KanjiLiteralQuestion> {
  bool loadingAudio = false;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.correctCharacter!.literal,
          style: const TextStyle(fontSize: 64),
        ),
        OutlinedButton(
            onPressed: () => playSound(
                widget.correctCharacter!.reading.map((e) => e.text).join(', '),
                widget.correctCharacter!.literal),
            child: const Text('Listen')),
        Text(
          widget.correctCharacter!.reading.map((e) => e.text).join(', '),
        ),
        ...widget.answers!.map(
          (e) => Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: TextButton(
                style:
                    ButtonStyle(backgroundColor: getBackgroundColor(e.correct)),
                onPressed: widget.answers!.any((e) => e.correct == true) ||
                        e.correct == false
                    ? null
                    : () => {widget.onPressAnswer(e)},
                child: Text(
                  e.meaning.join(', '),
                  style: const TextStyle(color: Colors.white),
                )),
          ),
        ),
      ],
    );
  }
}
