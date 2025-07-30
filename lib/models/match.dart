import 'team.dart';
import 'formation.dart';
import 'player.dart';

class Match {
  final Team homeTeam;
  final Team awayTeam;
  final Formation homeFormation;
  final Formation awayFormation;
  final DateTime date;
  final List<MatchEvent> events;
  final MatchStats stats;
  final MatchResult result;

  Match({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeFormation,
    required this.awayFormation,
    required this.date,
    required this.events,
    required this.stats,
    required this.result,
  });

  bool get isFinished => result.isFinished;
  bool get isHomeWin => result.homeGoals > result.awayGoals;
  bool get isAwayWin => result.awayGoals > result.homeGoals;
  bool get isDraw => result.homeGoals == result.awayGoals;

  Map<String, dynamic> toJson() {
    return {
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'homeFormation': homeFormation.name,
      'awayFormation': awayFormation.name,
      'date': date.toIso8601String(),
      'events': events.map((e) => e.toJson()).toList(),
      'stats': stats.toJson(),
      'result': result.toJson(),
    };
  }
}

class MatchEvent {
  final int minute;
  final MatchEventType type;
  final Player? player;
  final String description;
  final bool isHomeTeam;

  MatchEvent({
    required this.minute,
    required this.type,
    this.player,
    required this.description,
    required this.isHomeTeam,
  });

  Map<String, dynamic> toJson() {
    return {
      'minute': minute,
      'type': type.toString().split('.').last,
      'player': player?.toJson(),
      'description': description,
      'isHomeTeam': isHomeTeam,
    };
  }
}

enum MatchEventType {
  goal,
  yellowCard,
  redCard,
  substitution,
  chance,
  save,
  foul,
  corner,
  freeKick,
}

class MatchStats {
  final int homePossession;
  final int awayPossession;
  final int homeShots;
  final int awayShots;
  final int homeShotsOnTarget;
  final int awayShotsOnTarget;
  final int homeCorners;
  final int awayCorners;
  final int homeFouls;
  final int awayFouls;
  final int homeYellowCards;
  final int awayYellowCards;
  final int homeRedCards;
  final int awayRedCards;

  MatchStats({
    required this.homePossession,
    required this.awayPossession,
    required this.homeShots,
    required this.awayShots,
    required this.homeShotsOnTarget,
    required this.awayShotsOnTarget,
    required this.homeCorners,
    required this.awayCorners,
    required this.homeFouls,
    required this.awayFouls,
    required this.homeYellowCards,
    required this.awayYellowCards,
    required this.homeRedCards,
    required this.awayRedCards,
  });

  Map<String, dynamic> toJson() {
    return {
      'homePossession': homePossession,
      'awayPossession': awayPossession,
      'homeShots': homeShots,
      'awayShots': awayShots,
      'homeShotsOnTarget': homeShotsOnTarget,
      'awayShotsOnTarget': awayShotsOnTarget,
      'homeCorners': homeCorners,
      'awayCorners': awayCorners,
      'homeFouls': homeFouls,
      'awayFouls': awayFouls,
      'homeYellowCards': homeYellowCards,
      'awayYellowCards': awayYellowCards,
      'homeRedCards': homeRedCards,
      'awayRedCards': awayRedCards,
    };
  }
}

class MatchResult {
  final int homeGoals;
  final int awayGoals;
  final bool isFinished;

  MatchResult({
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.isFinished = false,
  });

  String get score => '$homeGoals - $awayGoals';
  bool get isHomeWin => homeGoals > awayGoals;
  bool get isAwayWin => awayGoals > homeGoals;
  bool get isDraw => homeGoals == awayGoals;
  String get resultText {
    if (!isFinished) return 'Devam ediyor';
    if (isHomeWin) return 'Ev sahibi kazandı';
    if (isAwayWin) return 'Deplasman kazandı';
    return 'Beraberlik';
  }

  Map<String, dynamic> toJson() {
    return {
      'homeGoals': homeGoals,
      'awayGoals': awayGoals,
      'isFinished': isFinished,
    };
  }
}
