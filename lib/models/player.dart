class Player {
  final String id;
  final String name;
  final String team;
  final Position position;
  final int age;
  final PlayerSkills skills;
  final int overall;

  Player({
    required this.id,
    required this.name,
    required this.team,
    required this.position,
    required this.age,
    required this.skills,
  }) : overall = _calculateOverall(skills);

  static int _calculateOverall(PlayerSkills skills) {
    int total = skills.pace +
        skills.shooting +
        skills.passing +
        skills.dribbling +
        skills.defending +
        skills.physical +
        skills.vision +
        skills.finishing +
        skills.stamina +
        skills.leadership;
    return (total / 10).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'team': team,
      'position': position.toString().split('.').last,
      'age': age,
      'skills': skills.toJson(),
      'overall': overall,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      team: json['team'],
      position: Position.values.firstWhere(
        (e) => e.toString().split('.').last == json['position'],
      ),
      age: json['age'],
      skills: PlayerSkills.fromJson(json['skills']),
    );
  }
}

class PlayerSkills {
  final int pace; // Hız
  final int shooting; // Şut
  final int passing; // Pas
  final int dribbling; // Dribling
  final int defending; // Savunma
  final int physical; // Fizik
  final int vision; // Görüş
  final int finishing; // Bitiricilik
  final int stamina; // Dayanıklılık
  final int leadership; // Liderlik

  PlayerSkills({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,
    required this.vision,
    required this.finishing,
    required this.stamina,
    required this.leadership,
  });

  Map<String, dynamic> toJson() {
    return {
      'pace': pace,
      'shooting': shooting,
      'passing': passing,
      'dribbling': dribbling,
      'defending': defending,
      'physical': physical,
      'vision': vision,
      'finishing': finishing,
      'stamina': stamina,
      'leadership': leadership,
    };
  }

  factory PlayerSkills.fromJson(Map<String, dynamic> json) {
    return PlayerSkills(
      pace: json['pace'],
      shooting: json['shooting'],
      passing: json['passing'],
      dribbling: json['dribbling'],
      defending: json['defending'],
      physical: json['physical'],
      vision: json['vision'],
      finishing: json['finishing'],
      stamina: json['stamina'],
      leadership: json['leadership'],
    );
  }
}

enum Position {
  goalkeeper, // Kaleci
  rightBack, // Sağ Bek
  centerBack, // Stoper
  leftBack, // Sol Bek
  defensiveMidfielder, // Defansif Orta Saha
  centralMidfielder, // Merkez Orta Saha
  attackingMidfielder, // Hücum Orta Saha
  rightWinger, // Sağ Kanat
  leftWinger, // Sol Kanat
  striker, // Forvet
}

extension PositionExtension on Position {
  String get displayName {
    switch (this) {
      case Position.goalkeeper:
        return 'Kaleci';
      case Position.rightBack:
        return 'Sağ Bek';
      case Position.centerBack:
        return 'Stoper';
      case Position.leftBack:
        return 'Sol Bek';
      case Position.defensiveMidfielder:
        return 'Defansif Orta Saha';
      case Position.centralMidfielder:
        return 'Merkez Orta Saha';
      case Position.attackingMidfielder:
        return 'Hücum Orta Saha';
      case Position.rightWinger:
        return 'Sağ Kanat';
      case Position.leftWinger:
        return 'Sol Kanat';
      case Position.striker:
        return 'Forvet';
    }
  }

  bool get isDefensive {
    return this == Position.goalkeeper ||
        this == Position.rightBack ||
        this == Position.centerBack ||
        this == Position.leftBack ||
        this == Position.defensiveMidfielder;
  }

  bool get isMidfield {
    return this == Position.centralMidfielder ||
        this == Position.attackingMidfielder;
  }

  bool get isAttacking {
    return this == Position.rightWinger ||
        this == Position.leftWinger ||
        this == Position.striker;
  }
}
