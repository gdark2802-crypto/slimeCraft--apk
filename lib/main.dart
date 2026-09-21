import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: SlimeCraft()));

class SlimeCraft extends StatefulWidget {
  @override
  _SlimeCraftState createState() => _SlimeCraftState();
}

class _SlimeCraftState extends State<SlimeCraft> with SingleTickerProviderStateMixin {
  double slimeX = 100, slimeY = 200;
  double velY = 0, velX = 0;
  bool onGround = false, left = false, right = false;
  int coins = 0, score = 0;
  List<Rect> blocks = [];
  List<Offset> coinsPos = [];
  late Timer gameLoop;

  @override
  void initState() {
    super.initState();
    // Nivel tipo Minecraft
    blocks = [
      Rect.fromLTWH(0, 500, 800, 40),
      Rect.fromLTWH(200, 420, 120, 20),
      Rect.fromLTWH(400, 350, 120, 20),
      Rect.fromLTWH(150, 280, 120, 20),
      Rect.fromLTWH(350, 200, 200, 20),
    ];
    coinsPos = [Offset(240, 390), Offset(440, 320), Offset(190, 250), Offset(400, 170)];
    
    gameLoop = Timer.periodic(Duration(milliseconds: 16), (t) {
      setState(() {
        // gravedad
        velY += 0.8;
        slimeY += velY;
        if (left) slimeX -= 5;
        if (right) slimeX += 5;
        
        // colisiones
        onGround = false;
        Rect slimeRect = Rect.fromLTWH(slimeX, slimeY, 50, 40);
        for (var b in blocks) {
          if (slimeRect.overlaps(b) && velY > 0 && slimeY + 40 < b.top + 15) {
            slimeY = b.top - 40;
            velY = 0;
            onGround = true;
          }
        }
        if (slimeY > 600) { slimeY = 100; slimeX = 100; velY = 0; }
        
        // monedas
        coinsPos.removeWhere((c) {
          if ((slimeX - c.dx).abs() < 40 && (slimeY - c.dy).abs() < 40) {
            coins++; score += 10; return true;
          }
          return false;
        });
        if (coinsPos.isEmpty) {
          coinsPos = [Offset(240, 390), Offset(440, 320), Offset(190, 250), Offset(400, 170)];
        }
      });
    });
  }

  void jump() { if (onGround) { velY = -18; onGround = false; } }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      body: Stack(
        children: [
          // bloques
          ...blocks.map((b) => Positioned(
            left: b.left, top: b.top, width: b.width, height: b.height,
            child: Container(decoration: BoxDecoration(color: Color(0xFF8B4513), border: Border.all(color: Color(0xFF5D2E0C), width: 3)), child: Container(margin: EdgeInsets.all(4), color: Color(0xFF4CAF50))),
          )),
          // monedas
          ...coinsPos.map((c) => Positioned(left: c.dx, top: c.dy, child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.yellow, shape: BoxShape.circle, border: Border.all(color: Colors.orange, width: 2))))),
          // slime
          Positioned(left: slimeX, top: slimeY, child: Container(width: 50, height: 40, decoration: BoxDecoration(color: Color(0xFF7ED957), borderRadius: BorderRadius.vertical(top: Radius.circular(20)), border: Border.all(color: Colors.green.shade800, width: 2)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle)), SizedBox(width: 12), Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle))]))),
          // UI
          Positioned(top: 40, left: 20, child: Text("SLIMECRAFT 🟩\nMonedas: $coins  Score: $score", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black)]))),
          // controles
          Positioned(bottom: 20, left: 20, right: 20, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              GestureDetector(onTapDown: (_) => left = true, onTapUp: (_) => left = false, child: _btn(Icons.arrow_back)),
              SizedBox(width: 20),
              GestureDetector(onTapDown: (_) => right = true, onTapUp: (_) => right = false, child: _btn(Icons.arrow_forward)),
            ]),
            GestureDetector(onTap: jump, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: Icon(Icons.arrow_upward, size: 40, color: Colors.white))),
          ])),
        ],
      ),
    );
  }
  Widget _btn(IconData i) => Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: Icon(i, color: Colors.white));
}
