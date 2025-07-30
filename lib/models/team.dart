import 'player.dart';

class Team {
  final String id;
  final String name;
  final String city;
  final String stadium;
  final int foundedYear;
  final List<Player> players;
  final TeamStats stats;

  Team({
    required this.id,
    required this.name,
    required this.city,
    required this.stadium,
    required this.foundedYear,
    required this.players,
    required this.stats,
  });

  int get averageOverall {
    if (players.isEmpty) return 0;
    int total = players.fold(0, (sum, player) => sum + player.overall);
    return (total / players.length).round();
  }

  List<Player> getPlayersByPosition(Position position) {
    return players.where((player) => player.position == position).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'stadium': stadium,
      'foundedYear': foundedYear,
      'players': players.map((p) => p.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      stadium: json['stadium'],
      foundedYear: json['foundedYear'],
      players:
          (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
      stats: TeamStats.fromJson(json['stats']),
    );
  }
}

class TeamStats {
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  TeamStats({
    this.matchesPlayed = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  int get points => (wins * 3) + draws;
  int get goalDifference => goalsFor - goalsAgainst;

  Map<String, dynamic> toJson() {
    return {
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
    };
  }

  factory TeamStats.fromJson(Map<String, dynamic> json) {
    return TeamStats(
      matchesPlayed: json['matchesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      draws: json['draws'] ?? 0,
      losses: json['losses'] ?? 0,
      goalsFor: json['goalsFor'] ?? 0,
      goalsAgainst: json['goalsAgainst'] ?? 0,
    );
  }

  TeamStats copyWith({
    int? matchesPlayed,
    int? wins,
    int? draws,
    int? losses,
    int? goalsFor,
    int? goalsAgainst,
  }) {
    return TeamStats(
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
    );
  }
}
