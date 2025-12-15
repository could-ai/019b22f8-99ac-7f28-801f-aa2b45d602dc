import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const KurdistanFlagApp());
}

class KurdistanFlagApp extends StatelessWidget {
  const KurdistanFlagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kurdistan Flag Animation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const FlagScreen(),
      },
    );
  }
}

class FlagScreen extends StatefulWidget {
  const FlagScreen({super.key});

  @override
  State<FlagScreen> createState() => _FlagScreenState();
}

class _FlagScreenState extends State<FlagScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('ئاڵای کوردستان - ڕۆژی ئاڵا'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'پیرۆزبێت ڕۆژی ئاڵای کوردستان',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial', 
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: FlagPainter(animationValue: _controller.value),
                    size: const Size(350, 230), // Aspect ratio approx 3:2
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'قوتابخانەی عادیلەخانم',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlagPainter extends CustomPainter {
  final double animationValue;

  FlagPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Flag Colors
    final redColor = const Color(0xFFEB2323);
    final whiteColor = Colors.white;
    final greenColor = const Color(0xFF278E43);
    final sunColor = const Color(0xFFFEBF10);

    // Wave parameters
    const waveAmplitude = 10.0;
    const waveFrequency = 2.5;
    
    // We will draw the flag by drawing vertical strips to simulate the wave
    // This allows the whole image (colors + sun + text) to wave together properly
    // However, drawing text strip by strip is hard. 
    // Instead, we will draw the background bands with paths that follow the sine wave.
    
    final pathRed = Path();
    final pathWhite = Path();
    final pathGreen = Path();

    double bandHeight = size.height / 3;

    // Construct paths for the three bands
    for (double x = 0; x <= size.width; x++) {
      // Calculate y offset based on sine wave
      // Moving the phase with animationValue
      double yOffset = math.sin((x / size.width * waveFrequency * math.pi) + (animationValue * 2 * math.pi)) * waveAmplitude;

      if (x == 0) {
        pathRed.moveTo(x, 0 + yOffset);
        pathWhite.moveTo(x, bandHeight + yOffset);
        pathGreen.moveTo(x, 2 * bandHeight + yOffset);
      } else {
        pathRed.lineTo(x, 0 + yOffset);
        pathWhite.lineTo(x, bandHeight + yOffset);
        pathGreen.lineTo(x, 2 * bandHeight + yOffset);
      }
    }

    // Close the paths
    // For Red: Top line is the wave, Bottom line is the wave at bandHeight
    // Actually, let's build closed shapes.
    
    // Re-doing paths to be closed shapes
    pathRed.reset();
    pathWhite.reset();
    pathGreen.reset();

    // Top edge of Red
    for (double x = 0; x <= size.width; x+=2) {
      double yOffset = _getWaveOffset(x, size.width);
      if (x==0) pathRed.moveTo(x, yOffset);
      else pathRed.lineTo(x, yOffset);
    }
    // Bottom edge of Red (which is top of White)
    for (double x = size.width; x >= 0; x-=2) {
      double yOffset = _getWaveOffset(x, size.width);
      pathRed.lineTo(x, bandHeight + yOffset);
    }
    pathRed.close();

    // Top edge of White (same as bottom of Red)
    for (double x = 0; x <= size.width; x+=2) {
      double yOffset = _getWaveOffset(x, size.width);
      if (x==0) pathWhite.moveTo(x, bandHeight + yOffset);
      else pathWhite.lineTo(x, bandHeight + yOffset);
    }
    // Bottom edge of White (top of Green)
    for (double x = size.width; x >= 0; x-=2) {
      double yOffset = _getWaveOffset(x, size.width);
      pathWhite.lineTo(x, 2 * bandHeight + yOffset);
    }
    pathWhite.close();

    // Top edge of Green
    for (double x = 0; x <= size.width; x+=2) {
      double yOffset = _getWaveOffset(x, size.width);
      if (x==0) pathGreen.moveTo(x, 2 * bandHeight + yOffset);
      else pathGreen.lineTo(x, 2 * bandHeight + yOffset);
    }
    // Bottom edge of Green
    for (double x = size.width; x >= 0; x-=2) {
      double yOffset = _getWaveOffset(x, size.width);
      pathGreen.lineTo(x, 3 * bandHeight + yOffset);
    }
    pathGreen.close();

    // Draw Bands
    paint.color = redColor;
    canvas.drawPath(pathRed, paint);
    
    paint.color = whiteColor;
    canvas.drawPath(pathWhite, paint);
    
    paint.color = greenColor;
    canvas.drawPath(pathGreen, paint);

    // Draw Sun
    // The sun should also bob up and down with the wave at the center
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double centerWaveOffset = _getWaveOffset(centerX, size.width);
    
    // Sun position
    Offset sunCenter = Offset(centerX, centerY + centerWaveOffset);
    double sunRadius = bandHeight * 0.7; // Sun diameter is usually smaller than white band, but rays extend
    double coreRadius = sunRadius * 0.5;

    paint.color = sunColor;
    
    // Draw Sun Rays
    int rayCount = 21;
    double angleStep = (2 * math.pi) / rayCount;
    // Rotate sun slowly
    double rotationOffset = animationValue * 2 * math.pi * 0.1; 

    Path sunPath = Path();
    for (int i = 0; i < rayCount; i++) {
      double angle = (i * angleStep) - (math.pi / 2) + rotationOffset;
      
      // Ray points
      // We want sharp rays. 
      // Point 1: on core circle
      // Point 2: tip of ray
      // Point 3: on core circle (next step)
      
      // Actually, standard star shape logic
      double rInner = coreRadius;
      double rOuter = sunRadius;
      
      // To make it look like the Kurdish sun (sharp rays)
      // We need 4 points per ray or just triangle rays
      // Let's draw the core circle first
      
      // Using a simpler star polygon approach
      // Base of ray on core
      double angle1 = angle - (angleStep / 4);
      double angle2 = angle + (angleStep / 4);
      
      Offset p1 = Offset(
        sunCenter.dx + math.cos(angle1) * rInner,
        sunCenter.dy + math.sin(angle1) * rInner,
      );
      Offset tip = Offset(
        sunCenter.dx + math.cos(angle) * rOuter,
        sunCenter.dy + math.sin(angle) * rOuter,
      );
      Offset p2 = Offset(
        sunCenter.dx + math.cos(angle2) * rInner,
        sunCenter.dy + math.sin(angle2) * rInner,
      );

      Path rayPath = Path();
      rayPath.moveTo(p1.dx, p1.dy);
      rayPath.lineTo(tip.dx, tip.dy);
      rayPath.lineTo(p2.dx, p2.dy);
      rayPath.close();
      canvas.drawPath(rayPath, paint);
    }
    
    // Draw Core Sun
    canvas.drawCircle(sunCenter, coreRadius, paint);

    // Draw Text
    // "قوتابخانەی عادیلەخانم" on top (Red area)
    // "ڕۆژی ئاڵا" on bottom (Green area)
    // We need to position them so they follow the wave roughly
    
    _drawText(
      canvas, 
      "قوتابخانەی عادیلەخانم", 
      Offset(centerX, bandHeight * 0.5 + _getWaveOffset(centerX, size.width)), 
      Colors.white,
      size.width * 0.07
    );

    _drawText(
      canvas, 
      "ڕۆژی ئاڵا", 
      Offset(centerX, bandHeight * 2.5 + _getWaveOffset(centerX, size.width)), 
      Colors.white,
      size.width * 0.07
    );
    
    // Add a "shine" or shadow overlay to enhance 3D effect
    // We draw a gradient over the whole flag that moves
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.black.withOpacity(0.0),
        Colors.black.withOpacity(0.1),
        Colors.white.withOpacity(0.1),
        Colors.black.withOpacity(0.1),
        Colors.black.withOpacity(0.0),
      ],
      stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
      transform: GradientRotation(0), // Can't easily rotate linear gradient in paint without shader
    );
    
    // We simulate the gradient moving by shifting the rect or using a shader
    // Simple shadow lines based on the derivative of the sine wave would be best but complex
    // Let's just leave it clean for now.
  }

  double _getWaveOffset(double x, double width) {
    const waveAmplitude = 10.0;
    const waveFrequency = 2.0;
    return math.sin((x / width * waveFrequency * math.pi) + (animationValue * 2 * math.pi)) * waveAmplitude;
  }

  void _drawText(Canvas canvas, String text, Offset center, Color color, double fontSize) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(blurRadius: 2, color: Colors.black45, offset: Offset(1, 1))
        ],
        fontFamily: 'Arial', // Fallback
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    // Draw centered at the offset
    textPainter.paint(
      canvas, 
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2)
    );
  }

  @override
  bool shouldRepaint(covariant FlagPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
