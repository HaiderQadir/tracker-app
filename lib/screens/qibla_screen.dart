import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../helpers/app_loader.dart';
import '../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  Future<void> _initQibla() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack(
          "Location services are disabled. Please enable them in Settings to continue.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack(
            "Location permission denied. Please enable them in Settings to continue.");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnack(
          "Location permission permanently denied. Please enable them in Settings to continue.");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final qibla = QiblaService.calculateQiblaDirection(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _qiblaDirection = qibla;
      _position = position;
    });
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Qibla Tracker",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: _initQibla,
        color: const Color(0xFF1F7CCD),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFf8f9fa),
                  Color(0xFF1F7CCD),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: _qiblaDirection == null
                  ? const AppCircularLoader()
                  : QiblaCompass(
                      qiblaDirection: _qiblaDirection!,
                      position: _position,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class QiblaCompass extends StatelessWidget {
  final double qiblaDirection;
  final Position? position;

  const QiblaCompass({
    super.key,
    required this.qiblaDirection,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Calibrating compass...");
        }

        final heading = snapshot.data!.heading;
        if (heading == null) {
          return const Text("Compass not available on this device");
        }

        double angle = (qiblaDirection - heading) * (pi / 180);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(1),
                    Colors.grey.shade200.withOpacity(1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Color(0xFF1F7CCD).withOpacity(0.3),
                  width: 16,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CustomPaint(
                        painter: _CompassPainter(),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: angle,
                    child: Icon(
                      Icons.navigation,
                      size: 120,
                      color: Color(0xFF1F7CCD),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(10, 5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Text(
                  "Qibla: ${qiblaDirection.toStringAsFixed(0)}° from North",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                if (position != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Lat: ${position!.latitude.toStringAsFixed(2)}, "
                    "Lng: ${position!.longitude.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    void drawText(String text, Offset offset) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
    }

    drawText("N", Offset(center.dx, center.dy - radius + 12));
    drawText("E", Offset(center.dx + radius - 12, center.dy));
    drawText("S", Offset(center.dx, center.dy + radius - 12));
    drawText("W", Offset(center.dx - radius + 12, center.dy));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
