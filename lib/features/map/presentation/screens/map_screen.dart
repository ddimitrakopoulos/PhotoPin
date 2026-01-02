import 'dart:async';
import 'dart:io';
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
    
    // Listen to memories changes to trigger rebuilds
    widget.memoriesController.addListener(_onMemoriesChanged);

    _mapSub = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveStart &&
          event.source != MapEventSource.mapController) {
        _followMe = false;
        if (mounted) setState(() {});
      }
    });
  }

  void _onMemoriesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.memoriesController.removeListener(_onMemoriesChanged);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Build without AnimatedBuilder - only rebuild on state changes
    if (widget.memoriesController.isLoading || !_hasInitialFix) {
      return const Center(child: CircularProgressIndicator());
    }

    final memories = widget.memoriesController.memories;

    return Stack(
      children: [
        // ───── GRAYSCALE MAP (BACKGROUND) ─────
        ColorFiltered(
          colorFilter: const ui.ColorFilter.matrix([
            // Complete desaturation (grayscale)
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
                    maxNativeZoom: 19,
                    // Performance optimizations
                    tileProvider: NetworkTileProvider(),
                    keepBuffer: 2,
                  ),
                ],
              ),
            ),

            // ───── GREY OVERLAY (EVERYWHERE EXCEPT SPOTLIGHTS) ─────
            StreamBuilder(
              stream: _mapController.mapEventStream,
              builder: (context, snapshot) {
                return IgnorePointer(
                  child: ClipPath(
                    clipper: _InverseSpotlightClipper(
                      mapController: _mapController,
                      memories: memories,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      color: isDark 
                          ? Colors.black.withOpacity(0.6)
                          : Colors.grey.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),

            // ───── NORMAL MAP (VISIBLE ONLY INSIDE SPOTLIGHTS) ─────
            StreamBuilder(
              stream: _mapController.mapEventStream,
              builder: (context, snapshot) {
                return ClipPath(
                  clipper: _SpotlightClipper(
                    mapController: _mapController,
                    memories: memories,
                  ),
                  child: ColorFiltered(
                    colorFilter: isDark 
                      ? const ui.ColorFilter.matrix([
                          // Dark mode: High contrast + High saturation
                          2.5, -0.75, -0.75, 0, -20,
                          -0.75, 2.5, -0.75, 0, -20,
                          -0.75, -0.75, 2.5, 0, -20,
                          0, 0, 0, 1, 0,
                        ])
                      : const ui.ColorFilter.matrix([
                          // Light mode: High saturation only
                          2.0, -0.5, -0.5, 0, 0,
                          -0.5, 2.0, -0.5, 0, 0,
                          -0.5, -0.5, 2.0, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.PhotoPin',
                          maxNativeZoom: 19,
                          // Performance optimizations
                          tileProvider: NetworkTileProvider(),
                          keepBuffer: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ───── GREY OVERLAY ON SPOTLIGHTS (DARK MODE ONLY) ─────
            if (isDark)
              StreamBuilder(
                stream: _mapController.mapEventStream,
                builder: (context, snapshot) {
                  return IgnorePointer(
                    child: ClipPath(
                      clipper: _SpotlightClipper(
                        mapController: _mapController,
                        memories: memories,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        color: Colors.grey.withOpacity(0.25),
                      ),
                    ),
                  );
                },
              ),

            // ───── RED DOTS ─────
            StreamBuilder(
              stream: _mapController.mapEventStream,
              builder: (context, snapshot) {
                return RedDotsOverlay(
                  mapController: _mapController,
                  memories: memories,
                  onTap: _onMemoryTap,
                );
              },
            ),

            // ───── USER LOCATION ─────
            if (_currentPosition != null)
              StreamBuilder(
                stream: _mapController.mapEventStream,
                builder: (context, snapshot) {
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
                },
              ),

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
  bool shouldReclip(covariant _SpotlightClipper oldClipper) {
    // Always reclip when camera moves to keep circles positioned over waypoints
    return true;
  }
}

// ───────────────────────── INVERSE SPOTLIGHT CLIPPER ─────────────────────────

class _InverseSpotlightClipper extends CustomClipper<ui.Path> {
  final MapController mapController;
  final List<Memory> memories;

  _InverseSpotlightClipper({
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

    // Start with full screen rectangle
    final path = ui.Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Subtract circles for each memory (creates cutouts)
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

    // Use even-odd fill rule to create inverse effect
    path.fillType = ui.PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant _InverseSpotlightClipper oldClipper) {
    // Always reclip when camera moves to keep circles positioned over waypoints
    return true;
  }
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

  // Group memories that are close together
  List<List<Memory>> _clusterMemories() {
    const double clusterDistanceThreshold = 30.0; // pixels (reduced from 50)
    final List<List<Memory>> clusters = [];
    final Set<String> processed = {};

    for (final memory in memories) {
      if (processed.contains(memory.id)) continue;

      final cluster = <Memory>[memory];
      processed.add(memory.id);

      final p1 = mapController.camera.latLngToScreenPoint(
        LatLng(memory.lat, memory.lng),
      );

      // Find all nearby memories
      for (final other in memories) {
        if (processed.contains(other.id)) continue;

        final p2 = mapController.camera.latLngToScreenPoint(
          LatLng(other.lat, other.lng),
        );

        final distance = math.sqrt(
          math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2),
        );

        if (distance <= clusterDistanceThreshold) {
          cluster.add(other);
          processed.add(other.id);
        }
      }

      clusters.add(cluster);
    }

    return clusters;
  }

  void _showMemoryPicker(BuildContext context, List<Memory> clusterMemories) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Memory',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: clusterMemories.length,
                  itemBuilder: (context, index) {
                    final memory = clusterMemories[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildMemoryThumbnail(memory),
                      ),
                      title: Text(
                        memory.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        memory.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        onTap(memory);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryThumbnail(Memory memory) {
    // User-captured image (file path)
    if (memory.imagePath != null && memory.imagePath!.isNotEmpty) {
      final imageFile = File(memory.imagePath!);
      
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          cacheWidth: 100, // Performance: cache at 2x size
          cacheHeight: 100,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade300,
              child: Icon(Icons.broken_image, color: Colors.grey.shade600, size: 24),
            );
          },
        );
      } else {
        return Container(
          width: 50,
          height: 50,
          color: Colors.grey.shade300,
          child: Icon(Icons.image_not_supported, color: Colors.grey.shade600, size: 24),
        );
      }
    }
    
    // Asset image
    return Image.asset(
      memory.imageAsset,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      cacheWidth: 100,
      cacheHeight: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clusters = _clusterMemories();

    return Stack(
      children: clusters.map((cluster) {
        // Use the first memory's position as the cluster position
        final representative = cluster.first;
        final p = mapController.camera
            .latLngToScreenPoint(LatLng(representative.lat, representative.lng));

        final isCluster = cluster.length > 1;

        return Positioned(
          left: p.x - (isCluster ? 12 : 8),
          top: p.y - (isCluster ? 12 : 8),
          child: GestureDetector(
            // More lenient tap detection
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isCluster) {
                _showMemoryPicker(context, cluster);
              } else {
                onTap(cluster.first);
              }
            },
            child: Container(
              // Larger tap target
              padding: const EdgeInsets.all(8),
              child: Container(
                width: isCluster ? 24 : 16,
                height: isCluster ? 24 : 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: isCluster
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: isCluster
                    ? Center(
                        child: Text(
                          '${cluster.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
