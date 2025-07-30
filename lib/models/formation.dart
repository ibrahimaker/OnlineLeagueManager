import 'player.dart';

class Formation {
  final String name;
  final List<PositionSlot> positions;
  final FormationStyle style;

  Formation({
    required this.name,
    required this.positions,
    required this.style,
  });

  static List<Formation> get defaultFormations => [
        Formation(
          name: '4-4-2',
          style: FormationStyle.balanced,
          positions: [
            PositionSlot(Position.goalkeeper, 0.5, 0.9),
            PositionSlot(Position.rightBack, 0.15, 0.75),
            PositionSlot(Position.centerBack, 0.35, 0.75),
            PositionSlot(Position.centerBack, 0.65, 0.75),
            PositionSlot(Position.leftBack, 0.85, 0.75),
            PositionSlot(Position.rightWinger, 0.15, 0.5),
            PositionSlot(Position.centralMidfielder, 0.35, 0.5),
            PositionSlot(Position.centralMidfielder, 0.65, 0.5),
            PositionSlot(Position.leftWinger, 0.85, 0.5),
            PositionSlot(Position.striker, 0.35, 0.25),
            PositionSlot(Position.striker, 0.65, 0.25),
          ],
        ),
        Formation(
          name: '4-3-3',
          style: FormationStyle.attacking,
          positions: [
            PositionSlot(Position.goalkeeper, 0.5, 0.9),
            PositionSlot(Position.rightBack, 0.15, 0.75),
            PositionSlot(Position.centerBack, 0.35, 0.75),
            PositionSlot(Position.centerBack, 0.65, 0.75),
            PositionSlot(Position.leftBack, 0.85, 0.75),
            PositionSlot(Position.defensiveMidfielder, 0.5, 0.6),
            PositionSlot(Position.centralMidfielder, 0.35, 0.5),
            PositionSlot(Position.centralMidfielder, 0.65, 0.5),
            PositionSlot(Position.rightWinger, 0.25, 0.3),
            PositionSlot(Position.striker, 0.5, 0.2),
            PositionSlot(Position.leftWinger, 0.75, 0.3),
          ],
        ),
        Formation(
          name: '3-5-2',
          style: FormationStyle.defensive,
          positions: [
            PositionSlot(Position.goalkeeper, 0.5, 0.9),
            PositionSlot(Position.centerBack, 0.25, 0.75),
            PositionSlot(Position.centerBack, 0.5, 0.75),
            PositionSlot(Position.centerBack, 0.75, 0.75),
            PositionSlot(Position.rightWinger, 0.15, 0.6),
            PositionSlot(Position.defensiveMidfielder, 0.5, 0.6),
            PositionSlot(Position.centralMidfielder, 0.35, 0.5),
            PositionSlot(Position.centralMidfielder, 0.65, 0.5),
            PositionSlot(Position.leftWinger, 0.85, 0.6),
            PositionSlot(Position.striker, 0.35, 0.25),
            PositionSlot(Position.striker, 0.65, 0.25),
          ],
        ),
        Formation(
          name: '4-2-3-1',
          style: FormationStyle.attacking,
          positions: [
            PositionSlot(Position.goalkeeper, 0.5, 0.9),
            PositionSlot(Position.rightBack, 0.15, 0.75),
            PositionSlot(Position.centerBack, 0.35, 0.75),
            PositionSlot(Position.centerBack, 0.65, 0.75),
            PositionSlot(Position.leftBack, 0.85, 0.75),
            PositionSlot(Position.defensiveMidfielder, 0.35, 0.6),
            PositionSlot(Position.defensiveMidfielder, 0.65, 0.6),
            PositionSlot(Position.rightWinger, 0.25, 0.4),
            PositionSlot(Position.attackingMidfielder, 0.5, 0.4),
            PositionSlot(Position.leftWinger, 0.75, 0.4),
            PositionSlot(Position.striker, 0.5, 0.2),
          ],
        ),
      ];
}

class PositionSlot {
  final Position position;
  final double x; // 0.0 - 1.0 (saha genişliği)
  final double y; // 0.0 - 1.0 (saha uzunluğu)
  Player? assignedPlayer;

  PositionSlot(this.position, this.x, this.y, {this.assignedPlayer});

  bool get isOccupied => assignedPlayer != null;

  void assignPlayer(Player player) {
    assignedPlayer = player;
  }

  void clearPlayer() {
    assignedPlayer = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position.toString().split('.').last,
      'x': x,
      'y': y,
      'assignedPlayer': assignedPlayer?.toJson(),
    };
  }

  factory PositionSlot.fromJson(Map<String, dynamic> json) {
    return PositionSlot(
      Position.values.firstWhere(
        (e) => e.toString().split('.').last == json['position'],
      ),
      json['x'],
      json['y'],
      assignedPlayer: json['assignedPlayer'] != null
          ? Player.fromJson(json['assignedPlayer'])
          : null,
    );
  }
}

enum FormationStyle {
  defensive,
  balanced,
  attacking,
}

extension FormationStyleExtension on FormationStyle {
  String get displayName {
    switch (this) {
      case FormationStyle.defensive:
        return 'Savunmacı';
      case FormationStyle.balanced:
        return 'Dengeli';
      case FormationStyle.attacking:
        return 'Hücumcu';
    }
  }
}
