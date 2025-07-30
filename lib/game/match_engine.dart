import 'dart:math';
import '../models/match.dart';
import '../models/formation.dart';
import '../models/player.dart';
import '../models/team.dart';

class MatchEngine {
  static MatchResult simulateMatch(Team homeTeam, Team awayTeam,
      Formation homeFormation, Formation awayFormation) {
    List<MatchEvent> events = [];
    MatchStats stats = MatchStats(
      homePossession: 0,
      awayPossession: 0,
      homeShots: 0,
      awayShots: 0,
      homeShotsOnTarget: 0,
      awayShotsOnTarget: 0,
      homeCorners: 0,
      awayCorners: 0,
      homeFouls: 0,
      awayFouls: 0,
      homeYellowCards: 0,
      awayYellowCards: 0,
      homeRedCards: 0,
      awayRedCards: 0,
    );

    int homeGoals = 0;
    int awayGoals = 0;
    Random random = Random();

    // Takım güçlerini hesapla
    double homeTeamStrength = _calculateTeamStrength(homeTeam, homeFormation);
    double awayTeamStrength = _calculateTeamStrength(awayTeam, awayFormation);

    // 90 dakika simülasyonu
    for (int minute = 1; minute <= 90; minute++) {
      // Her dakika için olay oluşturma şansı
      if (random.nextDouble() < 0.3) {
        // %30 şans
        MatchEvent? event = _generateRandomEvent(minute, homeTeam, awayTeam,
            homeTeamStrength, awayTeamStrength, random);
        if (event != null) {
          events.add(event);

          // İstatistikleri güncelle
          _updateStats(stats, event);

          // Gol sayılarını güncelle
          if (event.type == MatchEventType.goal) {
            if (event.isHomeTeam) {
              homeGoals++;
            } else {
              awayGoals++;
            }
          }
        }
      }
    }

    // Pozisyon istatistiklerini hesapla
    stats =
        _calculateFinalStats(stats, homeTeamStrength, awayTeamStrength, random);

    return MatchResult(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      isFinished: true,
    );
  }

  static double _calculateTeamStrength(Team team, Formation formation) {
    double totalStrength = 0;
    int playerCount = 0;

    // Formasyondaki pozisyonlara göre en iyi oyuncuları seç
    for (PositionSlot slot in formation.positions) {
      List<Player> availablePlayers = team.getPlayersByPosition(slot.position);
      if (availablePlayers.isNotEmpty) {
        // En yüksek overall'a sahip oyuncuyu seç
        Player bestPlayer =
            availablePlayers.reduce((a, b) => a.overall > b.overall ? a : b);
        totalStrength += bestPlayer.overall;
        playerCount++;
      }
    }

    // Formasyon stilinin etkisi
    double formationBonus = 1.0;
    switch (formation.style) {
      case FormationStyle.attacking:
        formationBonus = 1.1; // Hücum bonusu
        break;
      case FormationStyle.defensive:
        formationBonus = 0.9; // Savunma bonusu
        break;
      case FormationStyle.balanced:
        formationBonus = 1.0; // Dengeli
        break;
    }

    return playerCount > 0 ? (totalStrength / playerCount) * formationBonus : 0;
  }

  static MatchEvent? _generateRandomEvent(int minute, Team homeTeam,
      Team awayTeam, double homeStrength, double awayStrength, Random random) {
    double homeChance = homeStrength / (homeStrength + awayStrength);
    bool isHomeTeam = random.nextDouble() < homeChance;
    Team team = isHomeTeam ? homeTeam : awayTeam;

    // Olay türünü belirle
    double eventRoll = random.nextDouble();

    if (eventRoll < 0.1) {
      // %10 şans - Gol
      return _generateGoalEvent(minute, team, isHomeTeam, random);
    } else if (eventRoll < 0.15) {
      // %5 şans - Sarı kart
      return _generateCardEvent(
          minute, team, isHomeTeam, MatchEventType.yellowCard, random);
    } else if (eventRoll < 0.17) {
      // %2 şans - Kırmızı kart
      return _generateCardEvent(
          minute, team, isHomeTeam, MatchEventType.redCard, random);
    } else if (eventRoll < 0.25) {
      // %8 şans - Şut
      return _generateShotEvent(minute, team, isHomeTeam, random);
    } else if (eventRoll < 0.35) {
      // %10 şans - Korner
      return _generateCornerEvent(minute, team, isHomeTeam, random);
    } else if (eventRoll < 0.45) {
      // %10 şans - Faul
      return _generateFoulEvent(minute, team, isHomeTeam, random);
    } else if (eventRoll < 0.55) {
      // %10 şans - Serbest vuruş
      return _generateFreeKickEvent(minute, team, isHomeTeam, random);
    } else if (eventRoll < 0.65) {
      // %10 şans - Kurtarış
      return _generateSaveEvent(minute, team, isHomeTeam, random);
    } else if (eventRoll < 0.75) {
      // %10 şans - Fırsat
      return _generateChanceEvent(minute, team, isHomeTeam, random);
    } else {
      // %25 şans - Oyuncu değişikliği
      return _generateSubstitutionEvent(minute, team, isHomeTeam, random);
    }
  }

  static MatchEvent _generateGoalEvent(
      int minute, Team team, bool isHomeTeam, Random random) {
    List<Player> attackers =
        team.players.where((p) => p.position.isAttacking).toList();
    Player? scorer = attackers.isNotEmpty
        ? attackers[random.nextInt(attackers.length)]
        : null;

    List<String> goalDescriptions = [
      'Muhteşem bir gol!',
      'Harika bir bitiriş!',
      'Kaleciyi geçen mükemmel şut!',
      'Açıdan gelen güzel gol!',
      'Penaltıdan gol!',
      'Serbest vuruştan gol!',
      'Kornerden gelen gol!',
      'Hızlı kontra atakta gol!',
      'Uzaktan gelen güzel gol!',
      'Dribling sonrası gol!',
    ];

    String description =
        goalDescriptions[random.nextInt(goalDescriptions.length)];
    if (scorer != null) {
      description = '${scorer.name} - $description';
    }

    return MatchEvent(
      minute: minute,
      type: MatchEventType.goal,
      player: scorer,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static MatchEvent _generateCardEvent(int minute, Team team, bool isHomeTeam,
      MatchEventType cardType, Random random) {
    List<Player> players =
        team.players.where((p) => p.position != Position.goalkeeper).toList();
    Player? player =
        players.isNotEmpty ? players[random.nextInt(players.length)] : null;

    String cardText =
        cardType == MatchEventType.yellowCard ? 'Sarı kart' : 'Kırmızı kart';
    String description = '${player?.name ?? "Oyuncu"} $cardText aldı!';

    return MatchEvent(
      minute: minute,
      type: cardType,
      player: player,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static MatchEvent _generateShotEvent(
      int minute, Team team, bool isHomeTeam, Random random) {
    List<Player> attackers =
        team.players.where((p) => p.position.isAttacking).toList();
    Player? shooter = attackers.isNotEmpty
        ? attackers[random.nextInt(attackers.length)]
        : null;

    List<String> shotDescriptions = [
      'Şut! Kaleci kurtardı.',
      'Uzaktan şut! Dışarı.',
      'Açıdan şut! Köşe.',
      'Güzel şut! Direk.',
      'Hızlı şut! Kaleci zor kurtardı.',
    ];

    String description =
        shotDescriptions[random.nextInt(shotDescriptions.length)];
    if (shooter != null) {
      description = '${shooter.name} - $description';
    }

    return MatchEvent(
      minute: minute,
      type: MatchEventType.chance,
      player: shooter,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static MatchEvent _generateCornerEvent(
      int minute, Team team, bool isHomeTeam, Random random) {
    List<Player> players =
        team.players.where((p) => p.position != Position.goalkeeper).toList();
    Player? player =
        players.isNotEmpty ? players[random.nextInt(players.length)] : null;

    String description = '${player?.name ?? "Oyuncu"} korner kazandı!';

    return MatchEvent(
      minute: minute,
      type: MatchEventType.corner,
      player: player,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static MatchEvent _generateFoulEvent(
      int minute, Team team, bool isHomeTeam, Random random) {
    List<Player> players =
        team.players.where((p) => p.position != Position.goalkeeper).toList();
    Player? player =
        players.isNotEmpty ? players[random.nextInt(players.length)] : null;

    List<String> foulDescriptions = [
      'Sert müdahale!',
      'Taktik faul!',
      'Dikkatsiz müdahale!',
      'Sert çarpışma!',
      'Geç müdahale!',
    ];

    String description =
        foulDescriptions[random.nextInt(foulDescriptions.length)];
    if (player != null) {
      description = '${player.name} - $description';
    }

    return MatchEvent(
      minute: minute,
      type: MatchEventType.foul,
      player: player,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static MatchEvent _generateFreeKickEvent(
      int minute, Team team, bool isHomeTeam, Random random) {
    List<Player> players =
        team.players.where((p) => p.position != Position.goalkeeper).toList();
    Player? player =
        players.isNotEmpty ? players[random.nextInt(players.length)] : null;

    String description = '${player?.name ?? "Oyuncu"} serbest vuruş kazandı!';

    return MatchEvent(
      minute: minute,
      type: MatchEventType.freeKick,
      player: player,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static MatchEvent _generateSaveEvent(
      int minute, Team team, bool isHomeTeam, Random random) {
    List<Player> goalkeepers =
        team.players.where((p) => p.position == Position.goalkeeper).toList();
    Player? goalkeeper = goalkeepers.isNotEmpty ? goalkeepers.first : null;

    List<String> saveDescriptions = [
      'Muhteşem kurtarış!',
      'Zor kurtarış!',
      'Refleks kurtarış!',
      'Güzel kurtarış!',
      'Kaleci kurtardı!',
    ];

    String description =
        saveDescriptions[random.nextInt(saveDescriptions.length)];
    if (goalkeeper != null) {
      description = '${goalkeeper.name} - $description';
    }

    return MatchEvent(
      minute: minute,
      type: MatchEventType.save,
      player: goalkeeper,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static MatchEvent _generateChanceEvent(
      int minute, Team team, bool isHomeTeam, Random random) {
    List<Player> attackers =
        team.players.where((p) => p.position.isAttacking).toList();
    Player? player = attackers.isNotEmpty
        ? attackers[random.nextInt(attackers.length)]
        : null;

    List<String> chanceDescriptions = [
      'Büyük fırsat!',
      'Altın fırsat!',
      'Muhteşem pozisyon!',
      'Tek başına kalecinin karşısında!',
      'Açık pozisyon!',
    ];

    String description =
        chanceDescriptions[random.nextInt(chanceDescriptions.length)];
    if (player != null) {
      description = '${player.name} - $description';
    }

    return MatchEvent(
      minute: minute,
      type: MatchEventType.chance,
      player: player,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static MatchEvent _generateSubstitutionEvent(
      int minute, Team team, bool isHomeTeam, Random random) {
    List<Player> players =
        team.players.where((p) => p.position != Position.goalkeeper).toList();
    Player? player =
        players.isNotEmpty ? players[random.nextInt(players.length)] : null;

    String description = '${player?.name ?? "Oyuncu"} oyundan çıkarıldı!';

    return MatchEvent(
      minute: minute,
      type: MatchEventType.substitution,
      player: player,
      description: description,
      isHomeTeam: isHomeTeam,
    );
  }

  static void _updateStats(MatchStats stats, MatchEvent event) {
    if (event.isHomeTeam) {
      switch (event.type) {
        case MatchEventType.goal:
          // Gol istatistikleri zaten MatchResult'ta tutuluyor
          break;
        case MatchEventType.yellowCard:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards + 1,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards,
          );
          break;
        case MatchEventType.redCard:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards + 1,
            awayRedCards: stats.awayRedCards,
          );
          break;
        case MatchEventType.chance:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots + 1,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget + 1,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards,
          );
          break;
        case MatchEventType.corner:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners + 1,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards,
          );
          break;
        case MatchEventType.foul:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls + 1,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards,
          );
          break;
        default:
          break;
      }
    } else {
      // Away team için benzer işlemler
      switch (event.type) {
        case MatchEventType.yellowCard:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards + 1,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards,
          );
          break;
        case MatchEventType.redCard:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards + 1,
          );
          break;
        case MatchEventType.chance:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots + 1,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget + 1,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards,
          );
          break;
        case MatchEventType.corner:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners + 1,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards,
          );
          break;
        case MatchEventType.foul:
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots,
            homeShotsOnTarget: stats.homeShotsOnTarget,
            awayShotsOnTarget: stats.awayShotsOnTarget,
            homeCorners: stats.homeCorners,
            awayCorners: stats.awayCorners,
            homeFouls: stats.homeFouls,
            awayFouls: stats.awayFouls + 1,
            homeYellowCards: stats.homeYellowCards,
            awayYellowCards: stats.awayYellowCards,
            homeRedCards: stats.homeRedCards,
            awayRedCards: stats.awayRedCards,
          );
          break;
        default:
          break;
      }
    }
  }

  static MatchStats _calculateFinalStats(MatchStats stats, double homeStrength,
      double awayStrength, Random random) {
    // Pozisyon istatistiklerini hesapla
    int totalStrength = (homeStrength + awayStrength).round();
    int homePossession = ((homeStrength / totalStrength) * 100).round();
    int awayPossession = 100 - homePossession;

    // Rastgele varyasyon ekle
    homePossession += random.nextInt(20) - 10;
    awayPossession = 100 - homePossession;

    return MatchStats(
      homePossession: homePossession.clamp(20, 80),
      awayPossession: awayPossession.clamp(20, 80),
      homeShots: stats.homeShots + random.nextInt(10),
      awayShots: stats.awayShots + random.nextInt(10),
      homeShotsOnTarget: stats.homeShotsOnTarget + random.nextInt(5),
      awayShotsOnTarget: stats.awayShotsOnTarget + random.nextInt(5),
      homeCorners: stats.homeCorners + random.nextInt(8),
      awayCorners: stats.awayCorners + random.nextInt(8),
      homeFouls: stats.homeFouls + random.nextInt(15),
      awayFouls: stats.awayFouls + random.nextInt(15),
      homeYellowCards: stats.homeYellowCards + random.nextInt(3),
      awayYellowCards: stats.awayYellowCards + random.nextInt(3),
      homeRedCards: stats.homeRedCards,
      awayRedCards: stats.awayRedCards,
    );
  }
}
