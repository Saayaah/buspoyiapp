import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

// --- MAIN APP SETUP ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Poyi?',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// --- Auth Wrapper ---
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      if (name != null && name.isNotEmpty) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SplashScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}


// --- Login Screen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();

  Future<void> _saveNameAndContinue() async {
    if (_nameController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SplashScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_pin_circle, color: Color(0xFFF59E0B), size: 80),
              const SizedBox(height: 20),
              const Text(
                "Enthaa peru?",
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 32, color: Colors.white),
              ),
              const Text(
                "Enter your name to begin your journey of regret.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveNameAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Continue", style: TextStyle(fontSize: 18, color: Color(0xFF1E293B))),
              )
            ],
          ),
        ),
      ),
    );
  }
}


// --- SCREEN 0: Splash Screen (NEW REALISTIC ANIMATION) ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _sceneController;
  late AnimationController _runController;
  late Animation<double> _busAnimation;
  late Animation<double> _personAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _hillAnimation;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _sceneController = AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _runController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sceneController, curve: const Interval(0.85, 1.0, curve: Curves.easeIn)),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      _busAnimation = Tween<double>(begin: -150.0, end: screenWidth + 50).animate(
        CurvedAnimation(parent: _sceneController, curve: const Interval(0.0, 0.8, curve: Curves.easeIn)),
      );
      _personAnimation = Tween<double>(begin: -50.0, end: screenWidth * 0.6).animate(
        CurvedAnimation(parent: _sceneController, curve: const Interval(0.2, 1.0, curve: Curves.linear)),
      );
      _hillAnimation = Tween<double>(begin: 0.0, end: -screenWidth * 0.3).animate(
        CurvedAnimation(parent: _sceneController, curve: const Interval(0.0, 1.0, curve: Curves.linear)),
      );
      setState(() {});
      _sceneController.forward();
    });

    _sceneController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showText = true;
        });
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _sceneController.dispose();
    _runController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: AnimatedBuilder(
        animation: _sceneController,
        builder: (context, child) {
          return Stack(
            children: [
              // Scenery
              Positioned(
                left: _hillAnimation.value,
                bottom: 120,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width * 1.5, 150),
                  painter: HillPainter(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120,
                  color: const Color(0xFF556B2F), // Grass
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 70,
                  color: const Color(0xFF475569), // Road
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: RoadPainter(_sceneController.value),
                  ),
                ),
              ),

              // Animated elements
              AnimatedBuilder(
                animation: Listenable.merge([_sceneController, _runController]),
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        left: _busAnimation.value,
                        bottom: 60,
                        child: const Icon(Icons.directions_bus_filled, color: Color(0xFFF59E0B), size: 80),
                      ),
                      Positioned(
                        left: _personAnimation.value,
                        bottom: 70,
                        child: CustomPaint(
                          size: const Size(40, 70),
                          painter: RunningPersonPainter(_runController.value),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // The Text that fades in at the end
              if (_showText)
                Center(
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Bus Poyoo?', style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 52, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 10),
                        const Text('sheyyyy...', style: TextStyle(fontSize: 20, color: Color(0xFF1E293B))),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Custom Painter for the running silhouette
class RunningPersonPainter extends CustomPainter {
  final double animationValue;
  RunningPersonPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1E293B);
    
    double bob = math.sin(animationValue * math.pi * 2) * 3;
    canvas.translate(0, bob);

    // Head
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), 8, paint);
    // Torso
    final torsoPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.25)
      ..lineTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.6)
      ..close();
    canvas.drawPath(torsoPath, paint);

    // Arms
    final armAngle = math.sin(animationValue * math.pi * 2) * 0.8;
    // Back arm
    canvas.save();
    canvas.translate(size.width * 0.6, size.height * 0.3);
    canvas.rotate(-armAngle);
    canvas.drawRect(const Rect.fromLTWH(0, -4, 20, 8), paint);
    canvas.restore();
    // Front arm
    canvas.save();
    canvas.translate(size.width * 0.4, size.height * 0.3);
    canvas.rotate(armAngle);
    canvas.drawRect(const Rect.fromLTWH(-20, -4, 20, 8), paint);
    canvas.restore();
    
    // Legs
    final legAngle = math.sin(animationValue * math.pi * 2) * 0.9;
    // Back leg
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.6);
    canvas.rotate(-legAngle);
    canvas.drawRect(const Rect.fromLTWH(-4, 0, 8, 25), paint);
    canvas.restore();
    // Front leg
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.6);
    canvas.rotate(legAngle);
    canvas.drawRect(const Rect.fromLTWH(-4, 0, 8, 25), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for the road lines
class RoadPainter extends CustomPainter {
  final double animationValue;
  RoadPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 4;
    
    final double dashWidth = 50;
    final double dashSpace = 30;
    double startX = -((animationValue * (dashWidth + dashSpace) * 10) % (dashWidth + dashSpace));

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2), Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for the hills in the background
class HillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3A4A24);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.9, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// --- SCREEN 1: Home Screen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _busController, _fadeController;
  late Animation<Offset> _busAnimation;
  late Animation<double> _fadeAnimation;
  bool _buttonVisible = false;

  @override
  void initState() {
    super.initState();
    _busController = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _busAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(2.5, 0.0)).animate(CurvedAnimation(parent: _busController, curve: Curves.easeInOut));
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _busController.forward();
    _busController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _buttonVisible = true);
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _busController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF87CEEB), Color(0xFFF0F4F8)])),
        child: Stack(
          children: [
            Align(alignment: Alignment.bottomCenter, child: Container(height: 100, color: const Color(0xFF556B2F))),
            SlideTransition(
              position: _busAnimation,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(padding: const EdgeInsets.only(left: 50.0), child: Transform.scale(scale: 1.5, child: const Icon(Icons.directions_bus_filled, color: Color(0xFFF59E0B), size: 80))),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Bus Poyi...", style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 52, color: Color(0xFF1E293B))),
                    const SizedBox(height: 10),
                    const Text("aa vazhiku angu Poyi.", style: TextStyle(fontSize: 20, color: Color(0xFF475569))),
                    const SizedBox(height: 50),
                    if (_buttonVisible)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegretOMeterScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53E3E), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)), elevation: 8),
                        child: const Text('vaa nmk moonjiyath nokaam', style: TextStyle(fontSize: 22, color: Colors.white)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREEN 2: Regret-O-Meter Screen ---
class RegretOMeterScreen extends StatefulWidget {
  const RegretOMeterScreen({Key? key}) : super(key: key);
  @override
  _RegretOMeterScreenState createState() => _RegretOMeterScreenState();
}

class _RegretOMeterScreenState extends State<RegretOMeterScreen> {
  int _currentStep = 0;
  final Map<int, String> _answers = {}; // Now stores custom answers
  final _locationController = TextEditingController();
  final _customAnswerController = TextEditingController();
  bool _showFrustrationButton = true; 
  int? _selectedOptionIndex;

  final List<Question> _questions = [
    const Question(title: "Entha undaye?", subtitle: "How close were you, really?", options: [Option("Bus maari kayari", Icons.touch_app), Option("Bus nirthiyila", Icons.visibility_off), Option("Stop maari", Icons.wrong_location)]),
    const Question(title: "Entha Karanam?", subtitle: "What was the main culprit?", options: [Option("Phone-il Kalich irunnu", Icons.phone_android), Option("Snooze adich ", Icons.snooze),Option("Friendine Wait Cheythu", Icons.people)]),
    const Question(title: "Yaathra Evidekkayirunnu?", subtitle: "What grand destiny did you miss?", options: [Option("Office", Icons.work), Option("Date Aayirunnu - Kopp!", Icons.favorite), Option("Kalyanathinu - Sadya Missed!", Icons.celebration), Option("Cinema'kku - First Half Poyene", Icons.theaters)]),
    const Question(title: "Epozha?", subtitle: "When did this tragedy strike?", options: [Option("Raavile ", Icons.wb_sunny_outlined), Option("Uchakku ", Icons.sunny), Option("Vaikunneram", Icons.nightlight_round), Option("Raathri", Icons.nights_stay)]),
    const Question(title: "Ipoyethe avastha", subtitle: "How are you feeling right now?", options: [Option("Dark", Icons.sentiment_very_dissatisfied),Option("Adutha bus kittumenn pradheekshikunnu", Icons.people), Option("Ellam vidhi enn karudhunnu", Icons.self_improvement)])
  ];

  void _nextStep(int optionIndex, {String? customAnswer}) {
    setState(() {
      final question = _questions[_currentStep];
      if (customAnswer != null && customAnswer.isNotEmpty) {
        _answers[_currentStep] = customAnswer;
      } else {
        _answers[_currentStep] = question.options[optionIndex].text;
      }
      
      _selectedOptionIndex = null;
      _customAnswerController.clear();

      if (_currentStep < _questions.length - 1) {
        _currentStep++;
      }
    });
  }

  void _showFrustrationDialog() {
    setState(() {
      _showFrustrationButton = false;
    });
    showDialog(
      context: context,
      builder: (context) => const FrustrationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool allQuestionsAnswered = _answers.length == _questions.length;
    final bool isLocationStep = allQuestionsAnswered;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Regret-O-Meter™", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(animation),
                  child: child,
                ),
              );
            },
            child: isLocationStep ? _buildLocationStep() : _buildQuestionStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionStep() {
    final currentQuestion = _questions[_currentStep];
    final double progress = (_currentStep + 1) / (_questions.length + 1);
    return Column(
      key: ValueKey<int>(_currentStep),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: (_currentStep) / (_questions.length + 1), end: progress),
          builder: (context, value, _) => LinearProgressIndicator(value: value, backgroundColor: Colors.grey[300], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)), minHeight: 10),
        ),
        const SizedBox(height: 24),
        Text(currentQuestion.title, style: const TextStyle(fontFamily: 'Permanent Marker', fontSize: 36, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        Text(currentQuestion.subtitle, style: const TextStyle(fontSize: 18, color: Color(0xFF475569))),
        const SizedBox(height: 40),
        ...List.generate(currentQuestion.options.length, (index) {
          final option = currentQuestion.options[index];
          return AnimatedListItem(
            index: index,
            child: OptionCard(text: option.text, icon: option.icon, onTap: () => _nextStep(index)),
          );
        }),
        AnimatedListItem(
          index: currentQuestion.options.length,
          child: OptionCard(
            text: "kaaranam ithonm alla",
            icon: Icons.edit,
            onTap: () {
              setState(() {
                _selectedOptionIndex = currentQuestion.options.length;
              });
            },
          ),
        ),
        if (_selectedOptionIndex == currentQuestion.options.length)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: TextField(
              controller: _customAnswerController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Enter your reason...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _nextStep(currentQuestion.options.length, customAnswer: _customAnswerController.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildLocationStep() {
    final double progress = 1.0;
    return Column(
      key: const ValueKey<String>('location_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: (_questions.length) / (_questions.length + 1), end: progress),
          builder: (context, value, _) => LinearProgressIndicator(value: value, backgroundColor: Colors.grey[300], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)), minHeight: 10),
        ),
        const SizedBox(height: 24),
        const Text("Evidekkayirunnu Plan?", style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 36, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        const Text("Enter the destination you failed to reach.", style: TextStyle(fontSize: 18, color: Color(0xFF475569))),
        const SizedBox(height: 40),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Destination',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFF59E0B)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            if (_showFrustrationButton)
              ElevatedButton(
                onPressed: _showFrustrationDialog,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                child: const Text("Deshyam Theerkkan", style: TextStyle(fontSize: 16)),
              ),
            ElevatedButton(
              onPressed: () {
                if (_locationController.text.isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => TicketGenerationScreen(answers: _answers, destination: _locationController.text)));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
              child: const Text("Kanakku Edukku", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ],
    );
  }
}

class OptionCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const OptionCard({Key? key, required this.text, required this.icon, required this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF334155)),
              const SizedBox(width: 20),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class Question {
  final String title;
  final String subtitle;
  final List<Option> options;
  const Question({required this.title, required this.subtitle, required this.options});
}

class Option {
  final String text;
  final IconData icon;
  const Option(this.text, this.icon);
}

class FrustrationDialog extends StatefulWidget {
  const FrustrationDialog({Key? key}) : super(key: key);
  @override
  _FrustrationDialogState createState() => _FrustrationDialogState();
}

class _FrustrationDialogState extends State<FrustrationDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(_controller.value * 2 * math.pi) * 0.1,
          child: AlertDialog(
            title: const Text("frustration theerno!"),
            content: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.directions_bus, size: 100, color: Color(0xFFE53E3E)),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }
}


// --- SCREEN 3: Ticket Generation Screen ---
class TicketGenerationScreen extends StatefulWidget {
  final Map<int, String> answers;
  final String destination;
  const TicketGenerationScreen({Key? key, required this.answers, required this.destination}) : super(key: key);
  @override
  _TicketGenerationScreenState createState() => _TicketGenerationScreenState();
}

class _TicketGenerationScreenState extends State<TicketGenerationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shaniController;
  int _currentMessageIndex = 0;
  Timer? _timer;
  final List<String> _loadingMessages = ["Analyzing your 'Moonjal'...", "Calculating emotional damage...", "Consulting with the 'Loka Poraali' association...", "Applying extra fees for 'chali'...", "Printing your official 'nashta' ticket..."];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _shaniController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..forward();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentMessageIndex < _loadingMessages.length - 1) {
        setState(() => _currentMessageIndex++);
      } else {
        timer.cancel();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => OfficialTicketScreen(answers: widget.answers, destination: widget.destination)));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shaniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotationTransition(turns: _animationController, child: const Icon(Icons.settings, color: Color(0xFFF59E0B), size: 100)),
                const SizedBox(height: 40),
                const Text("Processing Regret", style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 32, color: Colors.white)),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(child: child, opacity: animation),
                  child: Text(_loadingMessages[_currentMessageIndex], key: ValueKey<int>(_currentMessageIndex), style: const TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 40),
                const Text("Shani Meter", style: TextStyle(color: Colors.white, fontSize: 20)),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: AnimatedBuilder(
                    animation: _shaniController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _shaniController.value,
                        backgroundColor: Colors.red[900],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                        minHeight: 15,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 4: Official Ticket Screen ---
class OfficialTicketScreen extends StatefulWidget {
  final Map<int, String> answers;
  final String destination;
  const OfficialTicketScreen({Key? key, required this.answers, required this.destination}) : super(key: key);

  @override
  State<OfficialTicketScreen> createState() => _OfficialTicketScreenState();
}

class _OfficialTicketScreenState extends State<OfficialTicketScreen> with TickerProviderStateMixin {
  String _remark = "Calculating...";
  String _userName = "...";
  String _pravachanam = "";
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    _generateAndSaveTicket();
    _animationController.forward();
    _playMusic();
  }

  Future<void> _playMusic() async {
    try {
      await _audioPlayer.play(AssetSource('audio/sad_violin.mp3'));
    } catch (e) {
      print("Error playing music: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getRemark() {
    int score = widget.answers.length;
    if (score > 4) return "Ticket Status: CONFIRMED";
    if (score > 2) return "Certified 'Moonjal'";
    return "ITHOKKE ENTHU!";
  }

  IconData _getIconForRemark(String remark) {
    if (remark.contains("status")) return Icons.emoji_events;
    if (remark.contains("Moonjal")) return Icons.favorite_border;
    return Icons.sentiment_neutral;
  }

  void _generatePravachanam() {
    final prophecies = [
      "Adutha businum late aavum. Oru chaya kudicho.",
      "Today's lucky color is yellow. Like the bus you missed.",
      "Don't worry, moonjal is a part of life.",
      "Your phone battery will die soon. Charge cheyyi.",
      "adutha vattam nokam ipo poko"
    ];
    final random = math.Random();
    setState(() {
      _pravachanam = prophecies[random.nextInt(prophecies.length)];
    });
  }

  Future<void> _generateAndSaveTicket() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? "A Fellow Sufferer";
    final remark = _getRemark();
    
    setState(() {
      _remark = remark;
      _userName = name;
    });

    final newTicket = RegretTicket(
      date: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      remark: remark,
      iconCodePoint: _getIconForRemark(remark).codePoint,
      destination: widget.destination,
      customAnswers: widget.answers.values.toList(),
    );
    await StorageService.addTicket(newTicket);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Moonjiyathinte aazham", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFF0F4F8), Colors.orange.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.0), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: Text("KITATHA BUS NTE TICKET", style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 24, color: Color(0xFF1E293B)))),
                      const Center(child: Text("The Regret Express", style: TextStyle(fontSize: 16, color: Colors.grey))),
                      const SizedBox(height: 20),
                      CustomPaint(painter: DashedLinePainter(), child: Container(height: 1)),
                      const SizedBox(height: 20),
                      Text("Name: $_userName", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text("Povan Iruna Sthalam: ${widget.destination}", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      const Text(" Time: A Moment Ago", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        child: Center(child: Text(_remark, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.redAccent, size: 40),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("CERTIFICATE OF MOONJAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                Text("Officially Certified by the All Kerala Bus Association", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExcuseNoteLoadingScreen(answers: widget.answers, destination: widget.destination)));
                },
                icon: const Icon(Icons.description),
                label: const Text("Get Official Excuse Note"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 252, 255, 92), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), textStyle: const TextStyle(fontSize: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _generatePravachanam,
                child: const Text("enk oru advice tharuuu", style: TextStyle(fontSize: 16)),
              ),
              if (_pravachanam.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text('"$_pravachanam"', style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.deepOrange), textAlign: TextAlign.center,),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HallOfRegretsScreen()));
                },
                child: const Text("View All My Regrets", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 9, dashSpace = 5, startX = 0;
    final paint = Paint()..color = Colors.grey.shade400..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// --- SCREEN 5: Hall of Regrets Screen ---
class HallOfRegretsScreen extends StatefulWidget {
  const HallOfRegretsScreen({Key? key}) : super(key: key);

  @override
  State<HallOfRegretsScreen> createState() => _HallOfRegretsScreenState();
}

class _HallOfRegretsScreenState extends State<HallOfRegretsScreen> {
  late Future<List<RegretTicket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = StorageService.getTickets();
  }

  void _refreshHistory() {
    setState(() {
      _ticketsFuture = StorageService.getTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hall of Regrets", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _refreshHistory)],
      ),
      backgroundColor: const Color(0xFFF0F4F8),
      body: FutureBuilder<List<RegretTicket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Your history is clean.\nSo far...", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.grey)),
            );
          }

          final tickets = snapshot.data!;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Icon(IconData(ticket.iconCodePoint, fontFamily: 'MaterialIcons'), color: const Color(0xFFF59E0B), size: 40),
                  title: Text(ticket.remark, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("To: ${ticket.destination} on ${ticket.date}", style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Failure Report on ${ticket.date}"),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: ticket.customAnswers.map((answer) => Text("- $answer")).toList(),
                          ),
                        ),
                        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- NEW: Excuse Note Loading Screen ---
class ExcuseNoteLoadingScreen extends StatefulWidget {
  final Map<int, String> answers;
  final String destination;
  const ExcuseNoteLoadingScreen({Key? key, required this.answers, required this.destination}) : super(key: key);
  @override
  _ExcuseNoteLoadingScreenState createState() => _ExcuseNoteLoadingScreenState();
}

class _ExcuseNoteLoadingScreenState extends State<ExcuseNoteLoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ExcuseNoteScreen(answers: widget.answers, destination: widget.destination)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E293B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            SizedBox(height: 20),
            Text("Contacting the Poya Bus Association...", style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// --- NEW: Excuse Note Screen ---
class ExcuseNoteScreen extends StatelessWidget {
  final Map<int, String> answers;
  final String destination;
  const ExcuseNoteScreen({Key? key, required this.answers, required this.destination}) : super(key: key);

  String _buildExcuse() {
    final reason = answers[1] ?? "an unknown reason";
    return "This is to formally certify that the aforementioned individual was regrettably delayed due to circumstances involving '$reason', and thereby missed their transport to '$destination'.\n\nThis incident has been officially recorded in our logs.\n\nSincerely,\nThe Poya Bus Association (Regd.)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Official Excuse Note", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        color: const Color(0xFFFDF6E3), // Parchment paper color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Poya Bus Association (Regd.)", style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 24)),
            const Text("Official Letterhead", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const Text("To Whom It May Concern,", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Text(_buildExcuse(), style: const TextStyle(fontSize: 16, height: 1.5, fontFamily: 'serif')),
            const Spacer(),
            Center(child: Icon(Icons.verified, size: 100, color: Colors.green.withOpacity(0.2))),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}


// --- DATA & STORAGE LOGIC ---
class RegretTicket {
  final String date;
  final String remark;
  final int iconCodePoint;
  final String destination;
  final List<String> customAnswers;

  const RegretTicket({required this.date, required this.remark, required this.iconCodePoint, required this.destination, required this.customAnswers});

  Map<String, dynamic> toJson() => {'date': date, 'remark': remark, 'iconCodePoint': iconCodePoint, 'destination': destination, 'customAnswers': customAnswers};

  factory RegretTicket.fromJson(Map<String, dynamic> json) {
    return RegretTicket(
      date: json['date'],
      remark: json['remark'],
      iconCodePoint: json['iconCodePoint'],
      destination: json['destination'] ?? 'Unknown',
      customAnswers: List<String>.from(json['customAnswers'] ?? []),
    );
  }
}

class StorageService {
  static const _key = 'regret_tickets';

  static Future<void> addTicket(RegretTicket newTicket) async {
    final prefs = await SharedPreferences.getInstance();
    final tickets = await getTickets();
    tickets.insert(0, newTicket);
    final String encodedData = jsonEncode(tickets.map((ticket) => ticket.toJson()).toList());
    await prefs.setString(_key, encodedData);
  }

  static Future<List<RegretTicket>> getTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_key);
    if (encodedData == null) {
      return [];
    }
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => RegretTicket.fromJson(item)).toList();
  }
}

// --- AnimatedListItem Widget ---
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  const AnimatedListItem({Key? key, required this.index, required this.child}) : super(key: key);

  @override
  _AnimatedListItemState createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
