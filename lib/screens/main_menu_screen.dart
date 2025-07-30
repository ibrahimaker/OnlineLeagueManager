import 'package:flutter/material.dart';
import 'team_selection_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ve başlık
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.sports_soccer,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'TÜRKIYE LIG\nMANAGER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Futbol Yöneticisi Oyunu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Menü butonları
                Container(
                  width: 300,
                  child: Column(
                    children: [
                      _buildMenuButton(
                        context,
                        'Yeni Oyun',
                        Icons.play_arrow,
                        () => _startNewGame(context),
                      ),
                      const SizedBox(height: 20),
                      _buildMenuButton(
                        context,
                        'Nasıl Oynanır',
                        Icons.help_outline,
                        () => _showHowToPlay(context),
                      ),
                      const SizedBox(height: 20),
                      _buildMenuButton(
                        context,
                        'Hakkında',
                        Icons.info_outline,
                        () => _showAbout(context),
                      ),
                      const SizedBox(height: 20),
                      _buildMenuButton(
                        context,
                        'Çıkış',
                        Icons.exit_to_app,
                        () => _exitGame(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Alt bilgi
                Text(
                  'Türkiye Süper Lig Takımları',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon,
      VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF3F4F6)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF1E3A8A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startNewGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TeamSelectionScreen(),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nasıl Oynanır'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Takım Seçimi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Türkiye Süper Lig\'inden bir takım seçin.'),
              SizedBox(height: 10),
              Text(
                '2. Taktik Belirleme',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('4-4-2, 4-3-3, 3-5-2 gibi formasyonlardan birini seçin.'),
              SizedBox(height: 10),
              Text(
                '3. Oyuncu Yerleştirme',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Sürükle-bırak ile oyuncularınızı formasyona yerleştirin.'),
              SizedBox(height: 10),
              Text(
                '4. Maç Başlatma',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Maçı başlatın ve canlı anlatımı takip edin.'),
              SizedBox(height: 10),
              Text(
                '5. İstatistikler',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Maç sırasında detaylı istatistikleri görün.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hakkında'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Türkiye Lig Manager',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text('Versiyon: 1.0.0'),
            SizedBox(height: 5),
            Text('Geliştirici: AI Assistant'),
            SizedBox(height: 10),
            Text(
              'Bu oyun, Türkiye Süper Lig takımlarını yönetebileceğiniz bir futbol manager oyunudur. Gerçekçi maç simülasyonu ve detaylı oyuncu istatistikleri ile gerçek bir teknik direktör deneyimi yaşayın.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _exitGame(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış'),
        content: const Text('Oyundan çıkmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Flutter'da uygulamayı kapatmak için
              // SystemNavigator.pop() kullanılabilir
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
    );
  }
}
