import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../memories/presentation/controllers/memories_controller.dart';
import '../../../memories/domain/memory.dart';
import '../../../memories/presentation/screens/photo_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.memoriesController});

  final MemoriesController memoriesController;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  LatLng? _currentPosition;
  bool _requestingLocation = false;

  StreamSubscription? _mapSub;
  StreamSubscription<Position>? _positionSub;

  bool _followMe = true;
  bool _hasInitialFix = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();

    _initLocation();

    _mapSub = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveStart &&
          event.source != MapEventSource.mapController) {
        _followMe = false;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _mapSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  // ───────────────────────── LOCATION ─────────────────────────

  Future<void> _initLocation() async {
    if (_requestingLocation) return;
    _requestingLocation = true;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        _currentPosition = LatLng(last.latitude, last.longitude);
        setState(() {});
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _hasInitialFix = true;
      setState(() {});
    } finally {
      _requestingLocation = false;
    }

    _positionSub ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((position) {
      if (!_followMe || !_mapReady) return;

      final next = LatLng(position.latitude, position.longitude);
      _currentPosition = next;
      setState(() {});

      _mapController.move(next, _mapController.camera.zoom);
    });
  }

  void _goToCurrentLocation() {
    if (_currentPosition != null && _mapReady) {
      _followMe = true;
      _mapController.move(_currentPosition!, 17);
    }
  }

  void _onMemoryTap(Memory memory) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoDetailScreen(
          memory: memory,
          memoriesController: widget.memoriesController,
        ),
      ),
    );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.memoriesController,
      builder: (_, _) {
        if (widget.memoriesController.isLoading || !_hasInitialFix) {
          return const Center(child: CircularProgressIndicator());
        }

        final memories = widget.memoriesController.memories;

        return Stack(
          children: [
            // ───── GRAYSCALE MAP (BACKGROUND) ─────
            ColorFiltered(
              colorFilter: const ui.ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition!,
                  initialZoom: 17,
                  minZoom: 3,
                  maxZoom: 25,
                  onMapReady: () {
                    _mapReady = true;
                    _mapController.move(_currentPosition!, 17);
                    setState(() {});
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.PhotoPin',
                  ),
                ],
              ),
            ),

            // ───── NORMAL MAP (VISIBLE ONLY INSIDE SPOTLIGHTS) ─────
            ClipPath(
              clipper: _SpotlightClipper(
                mapController: _mapController,
                memories: memories,
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: const MapOptions(),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.PhotoPin',
                  ),
                ],
              ),
            ),

            // ───── RED DOTS ─────
            RedDotsOverlay(
              mapController: _mapController,
              memories: memories,
              onTap: _onMemoryTap,
            ),

            // ───── USER LOCATION ─────
            if (_currentPosition != null)
              Builder(builder: (_) {
                final p = _mapController.camera
                    .latLngToScreenPoint(_currentPosition!);
                return Positioned(
                  left: p.x - 25,
                  top: p.y - 50,
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF5A5F),
                    size: 50,
                  ),
                );
              }),

            // ───── LOCATION BUTTON ─────
            Positioned(
              right: 16,
              bottom: 24,
              child: FloatingActionButton(
                mini: true,
                onPressed: _goToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ),

            // ───── ZOOM OUT BUTTON ─────
            Positioned(
              left: 16,
              bottom: 24,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'zoom_out',
                onPressed: () {
                  final camera = _mapController.camera;
                  if (camera.zoom > camera.minZoom!) {
                    _mapController.move(
                      camera.center,
                      camera.zoom - 1,
                    );
                  }
                },
                child: const Icon(Icons.remove),
              ),
            ),

            // ───── ZOOM IN BUTTON ─────
            Positioned(
              left: 16,
              bottom: 72,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'zoom_in',
                onPressed: () {
                  final camera = _mapController.camera;
                  if (camera.zoom < camera.maxZoom!) {
                    _mapController.move(
                      camera.center,
                      camera.zoom + 1,
                    );
                  }
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ───────────────────────── SPOTLIGHT CLIPPER ─────────────────────────

class _SpotlightClipper extends CustomClipper<ui.Path> {
  final MapController mapController;
  final List<Memory> memories;

  _SpotlightClipper({
    required this.mapController,
    required this.memories,
  });

  @override
  ui.Path getClip(Size size) {
    final camera = mapController.camera;

    // Base values
    const double baseRadius = 60;
    const double baseZoom = 17;

    // Zoom-normalized radius
    final scale = math.pow(2, camera.zoom - baseZoom).toDouble();

    // Clamp radius to reasonable min/max
    final radius = (baseRadius * scale).clamp(20.0, 140.0);

    final path = ui.Path();

    for (final m in memories) {
      final p = camera.latLngToScreenPoint(
        LatLng(m.lat, m.lng),
      );
      path.addOval(
        Rect.fromCircle(
          center: Offset(p.x.toDouble(), p.y.toDouble()),
          radius: radius,
        ),
      );
    }

    return path;
  }

  @override
  bool shouldReclip(_) => true;
}

// ───────────────────────── RED DOTS ─────────────────────────

class RedDotsOverlay extends StatelessWidget {
  final MapController mapController;
  final List<Memory> memories;
  final void Function(Memory) onTap;

  const RedDotsOverlay({
    super.key,
    required this.mapController,
    required this.memories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: memories.map((m) {
        final p = mapController.camera
            .latLngToScreenPoint(LatLng(m.lat, m.lng));

        return Positioned(
          left: p.x - 6,
          top: p.y - 6,
          child: GestureDetector(
            onTap: () => onTap(m),
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
