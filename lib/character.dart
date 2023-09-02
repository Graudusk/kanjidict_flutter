// To parse this JSON data, do
//
//     final character = characterFromJson(jsonString);

import 'dart:convert';

List<Character> charactersFromJson(String str) =>
    List<Character>.from(json.decode(str).map((x) => Character.fromJson(x)));

String charactersToJson(List<Character> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Character {
  final String literal;
  final List<String> radical;
  final Misc misc;
  final List<String> meaning;
  final List<Reading> reading;
  bool? correct;

  Character({
    required this.literal,
    required this.radical,
    required this.misc,
    required this.meaning,
    required this.reading,
  });

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        literal: json["literal"],
        radical: List<String>.from(json["radical"].map((x) => x)),
        misc: Misc.fromJson(json["misc"]),
        meaning: List<String>.from(json["meaning"].map((x) => x)),
        reading:
            List<Reading>.from(json["reading"].map((x) => Reading.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "literal": literal,
        "radical": List<dynamic>.from(radical.map((x) => x)),
        "misc": misc.toJson(),
        "meaning": List<dynamic>.from(meaning.map((x) => x)),
        "reading": List<dynamic>.from(reading.map((x) => x.toJson())),
      };
}

class Misc {
  final String grade;
  final dynamic strokeCount;
  final String freq;
  final String jlpt;
  final dynamic variant;

  Misc({
    required this.grade,
    required this.strokeCount,
    required this.freq,
    required this.jlpt,
    this.variant,
  });

  factory Misc.fromJson(Map<String, dynamic> json) => Misc(
        grade: json["grade"],
        strokeCount: json["stroke_count"],
        freq: json["freq"],
        jlpt: json["jlpt"],
        variant: json["variant"],
      );

  Map<String, dynamic> toJson() => {
        "grade": grade,
        "stroke_count": strokeCount,
        "freq": freq,
        "jlpt": jlpt,
        "variant": variant,
      };
}

class VariantElement {
  final String varType;
  final String text;

  VariantElement({
    required this.varType,
    required this.text,
  });

  factory VariantElement.fromJson(Map<String, dynamic> json) => VariantElement(
        varType: json["var_type"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "var_type": varType,
        "text": text,
      };
}

class Reading {
  final RType rType;
  final String text;

  Reading({
    required this.rType,
    required this.text,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        rType: rTypeValues.map[json["r_type"]]!,
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "r_type": rTypeValues.reverse[rType],
        "text": text,
      };
}

enum RType { JA_KUN, JA_ON }

final rTypeValues = EnumValues({"ja_kun": RType.JA_KUN, "ja_on": RType.JA_ON});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
