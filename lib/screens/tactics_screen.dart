import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/formation.dart';
import '../models/player.dart';
import 'match_screen.dart';

class TacticsScreen extends StatefulWidget {
  final Team selectedTeam;
  final Formation selectedFormation;

  const TacticsScreen({
    super.key,
    required this.selectedTeam,
    required this.selectedFormation,
  });

  @override
  State<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends State<TacticsScreen> {
  late Formation currentFormation;

  @override
  void initState() {
    super.initState();
    // Formasyonun bir kopyasını oluştur
    currentFormation = Formation(
      name: widget.selectedFormation.name,
      positions: widget.selectedFormation.positions
          .map((slot) => PositionSlot(slot.position, slot.x, slot.y))
          .toList(),
      style: widget.selectedFormation.style,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taktik Düzeni'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _autoAssignPlayers,
            tooltip: 'Otomatik Yerleştir',
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
            // Başlık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    '${widget.selectedTeam.name} - ${currentFormation.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Pozisyonlara tıklayarak oyuncu seçin',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Futbol sahası - tam ekran
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Stack(
                  children: [
                    // Saha çizgileri
                    _buildFieldLines(),

                    // Pozisyon slotları
                    ...currentFormation.positions
                        .map((slot) => _buildPositionSlot(slot))
                        .toList(),
                  ],
                ),
              ),
            ),

            // Alt butonlar
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _autoAssignPlayers,
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Otomatik Yerleştir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _canStartMatch() ? _startMatch : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Maçı Başlat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _canStartMatch() ? Colors.green : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLines() {
    return CustomPaint(
      size: Size.infinite,
      painter: FieldPainter(),
    );
  }

  Widget _buildPositionSlot(PositionSlot slot) {
    return Positioned(
      left: slot.x * (MediaQuery.of(context).size.width - 120) - 25,
      top: slot.y * (MediaQuery.of(context).size.height - 200) - 25,
      child: GestureDetector(
        onTap: () => _showPlayerSelectionDialog(slot),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: slot.isOccupied
                ? Colors.green.withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: slot.isOccupied ? Colors.green : Colors.white,
              width: 2,
            ),
          ),
          child: slot.isOccupied
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        slot.assignedPlayer!.name.split(' ').first,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${slot.assignedPlayer!.overall}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    slot.position.displayName.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _showPlayerSelectionDialog(PositionSlot slot) {
    // Bu pozisyon için uygun oyuncuları filtrele
    List<Player> suitablePlayers = widget.selectedTeam.players
        .where((player) => player.position == slot.position)
        .toList();

    // Eğer aynı pozisyonda oyuncu yoksa, benzer pozisyonlardan seç
    if (suitablePlayers.isEmpty) {
      if (slot.position.isDefensive) {
        suitablePlayers = widget.selectedTeam.players
            .where((player) => player.position.isDefensive)
            .toList();
      } else if (slot.position.isMidfield) {
        suitablePlayers = widget.selectedTeam.players
            .where((player) => player.position.isMidfield)
            .toList();
      } else if (slot.position.isAttacking) {
        suitablePlayers = widget.selectedTeam.players
            .where((player) => player.position.isAttacking)
            .toList();
      }
    }

    // Hala oyuncu bulunamadıysa, tüm oyuncuları göster
    if (suitablePlayers.isEmpty) {
      suitablePlayers = widget.selectedTeam.players;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${slot.position.displayName} Pozisyonu için Oyuncu Seç'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: suitablePlayers.length,
            itemBuilder: (context, index) {
              Player player = suitablePlayers[index];
              bool isAssigned = currentFormation.positions
                  .any((pos) => pos.assignedPlayer?.id == player.id);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPositionColor(player.position),
                  child: Text(
                    player.position.displayName.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  player.name,
                  style: TextStyle(
                    color: isAssigned ? Colors.grey : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${player.position.displayName} • ${player.overall}',
                  style: TextStyle(
                    color: isAssigned ? Colors.grey : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: isAssigned
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: isAssigned
                    ? null
                    : () {
                        setState(() {
                          // Önceki pozisyondan oyuncuyu kaldır
                          for (var pos in currentFormation.positions) {
                            if (pos.assignedPlayer?.id == player.id) {
                              pos.clearPlayer();
                            }
                          }
                          // Yeni pozisyona yerleştir
                          slot.assignPlayer(player);
                        });
                        Navigator.pop(context);
                      },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          if (slot.isOccupied)
            TextButton(
              onPressed: () {
                setState(() {
                  slot.clearPlayer();
                });
                Navigator.pop(context);
              },
              child: const Text('Kaldır'),
            ),
        ],
      ),
    );
  }

  Color _getPositionColor(Position position) {
    if (position.isDefensive) return Colors.blue;
    if (position.isMidfield) return Colors.orange;
    if (position.isAttacking) return Colors.red;
    return Colors.grey;
  }

  void _autoAssignPlayers() {
    setState(() {
      // Tüm pozisyonları temizle
      for (var slot in currentFormation.positions) {
        slot.clearPlayer();
      }

      // Her pozisyon için en uygun oyuncuyu bul ve yerleştir
      for (var slot in currentFormation.positions) {
        // Önce aynı pozisyondaki oyuncuları dene
        List<Player> availablePlayers = widget.selectedTeam.players
            .where((p) => p.position == slot.position)
            .where((p) => !currentFormation.positions
                .any((pos) => pos.assignedPlayer?.id == p.id))
            .toList();

        // Eğer aynı pozisyonda oyuncu yoksa, benzer pozisyonlardan seç
        if (availablePlayers.isEmpty) {
          if (slot.position.isDefensive) {
            availablePlayers = widget.selectedTeam.players
                .where((p) => p.position.isDefensive)
                .where((p) => !currentFormation.positions
                    .any((pos) => pos.assignedPlayer?.id == p.id))
                .toList();
          } else if (slot.position.isMidfield) {
            availablePlayers = widget.selectedTeam.players
                .where((p) => p.position.isMidfield)
                .where((p) => !currentFormation.positions
                    .any((pos) => pos.assignedPlayer?.id == p.id))
                .toList();
          } else if (slot.position.isAttacking) {
            availablePlayers = widget.selectedTeam.players
                .where((p) => p.position.isAttacking)
                .where((p) => !currentFormation.positions
                    .any((pos) => pos.assignedPlayer?.id == p.id))
                .toList();
          }
        }

        // Hala oyuncu bulunamadıysa, herhangi bir boş oyuncuyu al
        if (availablePlayers.isEmpty) {
          availablePlayers = widget.selectedTeam.players
              .where((p) => !currentFormation.positions
                  .any((pos) => pos.assignedPlayer?.id == p.id))
              .toList();
        }

        if (availablePlayers.isNotEmpty) {
          // En yüksek overall'a sahip oyuncuyu seç
          Player bestPlayer =
              availablePlayers.reduce((a, b) => a.overall > b.overall ? a : b);
          slot.assignPlayer(bestPlayer);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Oyuncular otomatik olarak yerleştirildi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  bool _canStartMatch() {
    return currentFormation.positions.every((slot) => slot.isOccupied);
  }

  void _startMatch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchScreen(
          selectedTeam: widget.selectedTeam,
          selectedFormation: currentFormation,
        ),
      ),
    );
  }
}

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Orta çizgi (yukarıdan aşağıya)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Orta saha dairesi
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      30,
      paint,
    );

    // Üst kale (soldan sağa)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, 0, size.width * 0.3, size.height * 0.1),
      paint,
    );

    // Alt kale (soldan sağa)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.9, size.width * 0.3,
          size.height * 0.1),
      paint,
    );

    // Üst penaltı noktası
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.15),
      3,
      paint,
    );

    // Alt penaltı noktası
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.85),
      3,
      paint,
    );

    // Üst ceza sahası
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, 0, size.width * 0.9, size.height * 0.25),
      paint,
    );

    // Alt ceza sahası
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.75, size.width * 0.9,
          size.height * 0.25),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
