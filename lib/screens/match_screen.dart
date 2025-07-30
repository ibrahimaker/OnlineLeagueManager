import 'package:flutter/material.dart';
import 'dart:async';
import '../models/team.dart';
import '../models/formation.dart';
import '../models/match.dart';
import '../game/match_engine.dart';
import '../data/turkish_league_data.dart';

class MatchScreen extends StatefulWidget {
  final Team selectedTeam;
  final Formation selectedFormation;

  const MatchScreen({
    super.key,
    required this.selectedTeam,
    required this.selectedFormation,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late Team opponentTeam;
  late Formation opponentFormation;
  late Match match;
  late MatchResult result;
  late MatchStats stats;
  List<MatchEvent> events = [];

  int currentMinute = 0;
  int homeGoals = 0;
  int awayGoals = 0;
  bool isMatchStarted = false;
  bool isMatchFinished = false;
  Timer? matchTimer;

  final ScrollController _eventsController = ScrollController();
  final ScrollController _statsController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeMatch();
  }

  @override
  void dispose() {
    matchTimer?.cancel();
    _eventsController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  void _initializeMatch() {
    // Rastgele rakip takım seç
    List<Team> availableTeams = TurkishLeagueData.teams
        .where((team) => team.id != widget.selectedTeam.id)
        .toList();
    opponentTeam = availableTeams[0]; // Basitlik için ilk takımı seç

    // Rastgele rakip formasyon seç
    opponentFormation = Formation.defaultFormations[0]; // 4-4-2

    // Başlangıç skoru 0-0
    homeGoals = 0;
    awayGoals = 0;

    // Maç istatistiklerini oluştur
    stats = MatchStats(
      homePossession: 50,
      awayPossession: 50,
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
  }

  void _startMatch() {
    setState(() {
      isMatchStarted = true;
    });

    // Her 2 saniyede bir dakika ilerlet
    matchTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        currentMinute++;

        // Maç olaylarını simüle et
        if (currentMinute % 3 == 0) {
          // Her 3 dakikada bir olay
          _generateRandomEvent();
        }

        if (currentMinute >= 90) {
          _endMatch();
          timer.cancel();
        }
      });

      // Otomatik scroll
      if (_eventsController.hasClients) {
        _eventsController.animateTo(
          _eventsController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _generateRandomEvent() {
    // Rastgele olay türü seç
    List<String> eventTypes = [
      'şut',
      'korner',
      'faul',
      'fırsat',
      'kurtarış',
      'gol',
      'pas'
    ];
    String eventType =
        eventTypes[DateTime.now().millisecondsSinceEpoch % eventTypes.length];

    String description = '';
    bool isHomeTeam =
        DateTime.now().millisecondsSinceEpoch % 2 == 0; // Rastgele takım seç

    // Rastgele oyuncu seç
    String randomPlayerName = '';
    if (isHomeTeam) {
      randomPlayerName = widget
          .selectedTeam
          .players[DateTime.now().millisecondsSinceEpoch %
              widget.selectedTeam.players.length]
          .name;
    } else {
      randomPlayerName = opponentTeam
          .players[DateTime.now().millisecondsSinceEpoch %
              opponentTeam.players.length]
          .name;
    }

    switch (eventType) {
      case 'gol':
        if (isHomeTeam) {
          homeGoals++;
          description = 'GOL! $randomPlayerName (${widget.selectedTeam.name})';
        } else {
          awayGoals++;
          description = 'GOL! $randomPlayerName (${opponentTeam.name})';
        }
        break;
      case 'şut':
        if (isHomeTeam) {
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots + 1,
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
            awayRedCards: stats.awayRedCards,
          );
          description =
              '$randomPlayerName (${widget.selectedTeam.name}) şut attı!';
        } else {
          stats = MatchStats(
            homePossession: stats.homePossession,
            awayPossession: stats.awayPossession,
            homeShots: stats.homeShots,
            awayShots: stats.awayShots + 1,
            homeShotsOnTarget: stats.homeShotsOnTarget,
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
          description = '$randomPlayerName (${opponentTeam.name}) şut attı!';
        }
        break;
      case 'korner':
        if (isHomeTeam) {
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
          description = '${widget.selectedTeam.name} korner kazandı!';
        } else {
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
          description = '${opponentTeam.name} korner kazandı!';
        }
        break;
      case 'faul':
        if (isHomeTeam) {
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
          description =
              '$randomPlayerName (${widget.selectedTeam.name}) faul yaptı!';
        } else {
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
          description = '$randomPlayerName (${opponentTeam.name}) faul yaptı!';
        }
        break;
      case 'fırsat':
        description = isHomeTeam
            ? '${widget.selectedTeam.name} büyük fırsat!'
            : '${opponentTeam.name} büyük fırsat!';
        break;
      case 'kurtarış':
        description = isHomeTeam
            ? '${widget.selectedTeam.name} kaleci kurtardı!'
            : '${opponentTeam.name} kaleci kurtardı!';
        break;
      case 'pas':
        description = isHomeTeam
            ? '$randomPlayerName (${widget.selectedTeam.name}) pas attı!'
            : '$randomPlayerName (${opponentTeam.name}) pas attı!';
        break;
    }

    events.add(MatchEvent(
      minute: currentMinute,
      type: eventType == 'gol' ? MatchEventType.goal : MatchEventType.chance,
      description: description,
      isHomeTeam: isHomeTeam,
    ));
  }

  void _endMatch() {
    setState(() {
      isMatchFinished = true;
    });

    // Maç sonucu mesajı
    String resultMessage = '';
    if (homeGoals > awayGoals) {
      resultMessage = 'Tebrikler! ${widget.selectedTeam.name} kazandı!';
    } else if (awayGoals > homeGoals) {
      resultMessage = '${opponentTeam.name} kazandı.';
    } else {
      resultMessage = 'Maç beraberlikle sonuçlandı.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultMessage),
        backgroundColor: homeGoals > awayGoals ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canlı Maç'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isMatchStarted)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _startMatch,
              tooltip: 'Maçı Başlat',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: Column(
          children: [
            // Maç durumu
            _buildMatchStatus(),

            // Ana içerik
            Expanded(
              child: Column(
                children: [
                  // Skor paneli
                  _buildScorePanel(),

                  // Maç olayları
                  Expanded(
                    flex: 1,
                    child: _buildEventsPanel(),
                  ),

                  // İstatistikler
                  Expanded(
                    flex: 1,
                    child: _buildStatsPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScorePanel() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ev sahibi takım
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.selectedTeam.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '$homeGoals',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // VS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'VS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Deplasman takımı
          Expanded(
            child: Column(
              children: [
                Text(
                  opponentTeam.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '$awayGoals',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isMatchFinished ? 'Maç Bitti' : 'Dakika: $currentMinute',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isMatchStarted && !isMatchFinished)
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsPanel() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Canlı Maç Anlatımı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _eventsController,
              padding: const EdgeInsets.all(10),
              itemCount: events.length,
              itemBuilder: (context, index) {
                MatchEvent event = events[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: event.isHomeTeam
                        ? _getTeamColor(widget.selectedTeam.name)
                            .withOpacity(0.1)
                        : _getTeamColor(opponentTeam.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: event.isHomeTeam
                          ? _getTeamColor(widget.selectedTeam.name)
                          : _getTeamColor(opponentTeam.name),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.isHomeTeam
                              ? _getTeamColor(widget.selectedTeam.name)
                              : _getTeamColor(opponentTeam.name),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${event.minute}\'',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          event.description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'İstatistikler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _statsController,
              padding: const EdgeInsets.all(10),
              children: [
                _buildStatRow('Pozisyon', '${stats.homePossession}%',
                    '${stats.awayPossession}%'),
                _buildStatRow(
                    'Şut', '${stats.homeShots}', '${stats.awayShots}'),
                _buildStatRow('İsabetli', '${stats.homeShotsOnTarget}',
                    '${stats.awayShotsOnTarget}'),
                _buildStatRow(
                    'Korner', '${stats.homeCorners}', '${stats.awayCorners}'),
                _buildStatRow(
                    'Faul', '${stats.homeFouls}', '${stats.awayFouls}'),
                _buildStatRow('Sarı', '${stats.homeYellowCards}',
                    '${stats.awayYellowCards}'),
                _buildStatRow('Kırmızı', '${stats.homeRedCards}',
                    '${stats.awayRedCards}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String homeValue, String awayValue) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                homeValue,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                awayValue,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Takım renklerini döndüren yardımcı metod
Color _getTeamColor(String teamName) {
  switch (teamName) {
    case 'Fenerbahçe':
      return Colors.yellow;
    case 'Galatasaray':
      return Colors.red;
    case 'Beşiktaş':
      return Colors.black;
    case 'Trabzonspor':
      return const Color(0xFF8B0000); // Koyu kırmızı
    case 'Adana Demirspor':
      return Colors.blue;
    case 'Antalyaspor':
      return Colors.red;
    case 'Konyaspor':
      return Colors.green;
    case 'Kayserispor':
      return Colors.red;
    case 'Alanyaspor':
      return Colors.orange;
    case 'Sivasspor':
      return Colors.red;
    case 'Kasımpaşa':
      return Colors.blue;
    case 'Fatih Karagümrük':
      return Colors.red;
    case 'İstanbul Başakşehir':
      return Colors.orange;
    case 'Gaziantep FK':
      return Colors.red;
    case 'Hatayspor':
      return Colors.orange;
    case 'Giresunspor':
      return Colors.green;
    case 'Ankaragücü':
      return Colors.yellow;
    case 'Pendikspor':
      return Colors.blue;
    case 'Samsunspor':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
