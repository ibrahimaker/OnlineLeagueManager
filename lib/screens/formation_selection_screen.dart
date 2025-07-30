import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/formation.dart';
import 'tactics_screen.dart';

class FormationSelectionScreen extends StatefulWidget {
  final Team selectedTeam;

  const FormationSelectionScreen({
    super.key,
    required this.selectedTeam,
  });

  @override
  State<FormationSelectionScreen> createState() =>
      _FormationSelectionScreenState();
}

class _FormationSelectionScreenState extends State<FormationSelectionScreen> {
  Formation? selectedFormation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formasyon Seçimi'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
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
            // Takım bilgisi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    widget.selectedTeam.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Formasyon seçin ve taktiklerinizi belirleyin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Seçili formasyon bilgisi
            if (selectedFormation != null)
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 30,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFormation!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            selectedFormation!.style.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '${selectedFormation!.positions.length} oyuncu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Formasyon listesi
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: Formation.defaultFormations.length,
                    itemBuilder: (context, index) {
                      Formation formation = Formation.defaultFormations[index];
                      bool isSelected =
                          selectedFormation?.name == formation.name;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E3A8A).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF1E3A8A), width: 2)
                              : null,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getFormationColor(formation.style),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                formation.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            formation.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formation.style.displayName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    _getFormationIcon(formation.style),
                                    size: 14,
                                    color: _getFormationColor(formation.style),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${formation.positions.length} pozisyon',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1E3A8A),
                                  size: 24,
                                )
                              : const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                          onTap: () {
                            setState(() {
                              selectedFormation = formation;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Devam et butonu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: selectedFormation != null
                    ? () => _continueToTactics(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Taktikleri Belirle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFormationColor(FormationStyle style) {
    switch (style) {
      case FormationStyle.attacking:
        return Colors.red;
      case FormationStyle.defensive:
        return Colors.blue;
      case FormationStyle.balanced:
        return Colors.green;
    }
  }

  IconData _getFormationIcon(FormationStyle style) {
    switch (style) {
      case FormationStyle.attacking:
        return Icons.trending_up;
      case FormationStyle.defensive:
        return Icons.shield;
      case FormationStyle.balanced:
        return Icons.balance;
    }
  }

  void _continueToTactics(BuildContext context) {
    if (selectedFormation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TacticsScreen(
            selectedTeam: widget.selectedTeam,
            selectedFormation: selectedFormation!,
          ),
        ),
      );
    }
  }
}
