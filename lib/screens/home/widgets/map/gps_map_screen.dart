import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/translations.dart';
import '../../../../providers/app_provider.dart';
import '../../../../theme.dart';

class GpsMapScreen extends StatefulWidget {
  const GpsMapScreen({super.key});

  @override
  State<GpsMapScreen> createState() => _GpsMapScreenState();
}

class _GpsMapScreenState extends State<GpsMapScreen> {
  // Submarine state — mirrors the React useState values
  double _lat = 10.82;
  double _lng = 108.20;
  double _depth = -35;
  double _heading = 60;
  double _speed = 4.2;

  // Trail — last 40 positions
  final List<LatLng> _trail = [
    LatLng(10.70, 107.9),
    LatLng(10.74, 108.0),
    LatLng(10.78, 108.1),
    LatLng(10.82, 108.2),
  ];

  bool _showPopup = false;
  Timer? _moveTimer;
  final MapController _mapCtrl = MapController();

  @override
  void initState() {
    super.initState();
    // Animate submarine every 2 seconds — mirrors the React useEffect
    _moveTimer = Timer.periodic(const Duration(seconds: 2), (_) => _moveSub());
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

  void _moveSub() {
    if (!mounted) return;
    final rad = (_heading * math.pi) / 180;
    var newLat = _lat + math.cos(rad) * 0.003;
    var newLng = _lng + math.sin(rad) * 0.003;
    var newHeading = _heading;

    // Bounce at boundary — mirrors the React heading flip logic
    if (newLat > 12 || newLat < 9) newHeading = (newHeading + 180) % 360;
    if (newLng > 110 || newLng < 106) newHeading = (360 - newHeading + 180) % 360;

    setState(() {
      _lat = newLat;
      _lng = newLng;
      _heading = newHeading;
      _trail.add(LatLng(newLat, newLng));
      if (_trail.length > 40) _trail.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppProvider>().t;
    final lang = context.watch<AppProvider>().lang;
    final subPos = LatLng(_lat, _lng);

    return Column(
      children: [
        // ── Info bar
        _buildInfoBar(t),

        // ── Map
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapCtrl,
                options: MapOptions(
                  initialCenter: const LatLng(10.8, 108.5),
                  initialZoom: 7,
                  onTap: (_, __) => setState(() => _showPopup = false),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.nauticom.submarine',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _trail,
                        strokeWidth: 2,
                        color: AppColors.blue.withValues(alpha: 0.7),
                        pattern: StrokePattern.dashed(
                          segments: [12, 8],
                        ),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: subPos,
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _showPopup = !_showPopup),
                          child: _SubmarineIcon(heading: _heading),
                        ),
                      ),
                    ],
                  ),
                  if (_showPopup)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_lat + 0.08, _lng),
                          width: 200,
                          height: 120,
                          child: _SubPopup(
                            lat: _lat,
                            lng: _lng,
                            depth: _depth,
                            speed: _speed,
                            heading: _heading,
                            t: t,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Dark tint — military map aesthetic (replaces Google Maps dark styles)
              IgnorePointer(
                child: Container(
                  color: AppColors.background.withValues(alpha: 0.45),
                ),
              ),

              // Compass overlay (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: _CompassWidget(heading: _heading),
              ),

              // Live tracking pill (bottom-left)
              Positioned(
                bottom: 12,
                left: 12,
                child: _buildTrackingPill(lang),
              ),

              // OSM attribution (bottom-right, required by OSM terms)
              Positioned(
                bottom: 4,
                right: 8,
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBar(AppTranslations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface.withOpacity(0.7),
      child: Row(
        children: [
          const Icon(Icons.navigation, color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_lat.toStringAsFixed(4)}°N, ${_lng.toStringAsFixed(4)}°E',
                style: const TextStyle(
                    color: AppColors.accent, fontSize: 12),
              ),
              Text(t.currentPos,
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 9)),
            ],
          ),
          const Spacer(),
          _statChip('${_depth.toStringAsFixed(0)}m', t.depth, AppColors.blue),
          const SizedBox(width: 12),
          _statChip('${_heading.toStringAsFixed(0)}°', t.heading, AppColors.amber),
          const SizedBox(width: 12),
          _statChip('${_speed.toStringAsFixed(1)} kn', t.speed, AppColors.accent),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: TextStyle(color: color, fontSize: 12)),
        Text(label,
            style: const TextStyle(color: AppColors.muted, fontSize: 9)),
      ],
    );
  }

  Widget _buildTrackingPill(Lang lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            lang == Lang.vi ? 'ĐANG THEO DÕI' : 'TRACKING LIVE',
            style: const TextStyle(
                color: AppColors.accent, fontSize: 10, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Submarine icon — drawn with CustomPaint (replaces SVG)
// ──────────────────────────────────────────────────────
class _SubmarineIcon extends StatelessWidget {
  final double heading;
  const _SubmarineIcon({required this.heading});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: (heading - 90) * math.pi / 180,
      child: SizedBox(
        width: 48,
        height: 48,
        child: CustomPaint(painter: _SubmarinePainter()),
      ),
    );
  }
}

class _SubmarinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Sonar ping ring
    canvas.drawCircle(
      Offset(cx, cy),
      16,
      Paint()
        ..color = AppColors.accent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Hull (ellipse)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 28, height: 12),
      Paint()..color = AppColors.accent.withOpacity(0.9),
    );

    // Conning tower
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 4), width: 8, height: 10),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF00cc88),
    );

    // Center dot
    canvas.drawCircle(
      Offset(cx, cy + 2),
      3,
      Paint()..color = AppColors.background,
    );
  }

  @override
  bool shouldRepaint(_SubmarinePainter _) => false;
}

// ──────────────────────────────────────────────────────
// Info popup shown when submarine marker is tapped
// ──────────────────────────────────────────────────────
class _SubPopup extends StatelessWidget {
  final double lat, lng, depth, speed, heading;
  final AppTranslations t;
  const _SubPopup({
    required this.lat,
    required this.lng,
    required this.depth,
    required this.speed,
    required this.heading,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🚢 NAUTICOM SUB-1',
              style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${lat.toStringAsFixed(4)}°N, ${lng.toStringAsFixed(4)}°E',
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text('${t.depth}: ${depth.toStringAsFixed(0)}m',
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text('${t.speed}: ${speed.toStringAsFixed(1)} kn',
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text('${t.heading}: ${heading.toStringAsFixed(0)}°',
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Compass overlay widget
// ──────────────────────────────────────────────────────
class _CompassWidget extends StatelessWidget {
  final double heading;
  const _CompassWidget({required this.heading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface.withOpacity(0.85),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: heading * math.pi / 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 2, height: 16, color: AppColors.accent),
                Container(width: 2, height: 12, color: AppColors.muted),
              ],
            ),
          ),
          // Cardinal labels
          const Positioned(top: 4, child: _CardinalLabel('N', AppColors.accent)),
          const Positioned(bottom: 4, child: _CardinalLabel('S', AppColors.muted)),
          const Positioned(left: 4, child: _CardinalLabel('W', AppColors.muted)),
          const Positioned(right: 4, child: _CardinalLabel('E', AppColors.muted)),
        ],
      ),
    );
  }
}

class _CardinalLabel extends StatelessWidget {
  final String letter;
  final Color color;
  const _CardinalLabel(this.letter, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(letter, style: TextStyle(color: color, fontSize: 8));
  }
}
