import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/login_flow_widgets.dart';

/// Step between signup and profession selection — lets the user drop a pin
/// on the map or use their current GPS location.
class ChooseLocationScreen extends StatefulWidget {
  const ChooseLocationScreen({
    super.key,
    required this.args,
    this.isLocationUpdate = false,
  });

  final SignupFlowArgs args;

  /// True when opened from Home to change the saved address, rather than
  /// as part of the signup flow — confirming should return to Home instead
  /// of continuing on to profession selection.
  final bool isLocationUpdate;

  @override
  State<ChooseLocationScreen> createState() => _ChooseLocationScreenState();
}

class _PickedPlace {
  const _PickedPlace(this.line1, this.line2);
  final String line1;
  final String line2;
}

class _SearchHit {
  const _SearchHit({
    required this.title,
    required this.subtitle,
    required this.point,
  });

  final String title;
  final String subtitle;
  final LatLng point;
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen>
    with SingleTickerProviderStateMixin {
  static const _defaultCenter = LatLng(28.6139, 77.2090); // New Delhi fallback

  bool _locating = false;
  bool _located = false;
  bool _searching = false;
  _PickedPlace? _place;
  List<_SearchHit> _searchHits = const [];
  Timer? _geocodeDebounce;
  late final AnimationController _pinController;
  late final MapController _mapController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _mapController = MapController();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useCurrentLocation();
    });
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _pinController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    _pinController.repeat(reverse: true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turn on location services to continue')),
        );
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is needed to pin your address'),
          ),
        );
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }
        return;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        await _applyLatLng(
          LatLng(lastKnown.latitude, lastKnown.longitude),
          moveMap: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!mounted) return;
      await _applyLatLng(
        LatLng(position.latitude, position.longitude),
        moveMap: true,
      );
    } catch (error) {
      if (!mounted || _located) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get your location: $error')),
      );
    } finally {
      _pinController
        ..stop()
        ..value = 0;
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  void _moveMap(LatLng point) {
    try {
      _mapController.move(point, 16);
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(point, 16);
        } catch (_) {}
      });
    }
  }

  Future<void> _applyLatLng(LatLng point, {required bool moveMap}) async {
    if (moveMap) _moveMap(point);
    final place = await _reverseGeocode(point);
    if (!mounted) return;
    setState(() {
      _place = place;
      _located = true;
    });
  }

  Future<_PickedPlace> _reverseGeocode(LatLng point) async {
    try {
      final marks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (marks.isEmpty) {
        return _fallbackPlace(point);
      }
      final p = marks.first;
      final line1 = _joinPlaceParts([
        p.name,
        p.street,
        p.subLocality,
        p.thoroughfare,
      ]);
      final line2 = _joinPlaceParts([
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.postalCode,
      ]);
      return _PickedPlace(
        line1.isEmpty ? 'Pinned location' : line1,
        line2.isEmpty ? 'Dropped pin' : line2,
      );
    } catch (_) {
      return _fallbackPlace(point);
    }
  }

  String _joinPlaceParts(List<String?> parts) {
    final seen = <String>{};
    final useful = <String>[];
    for (final part in parts) {
      final text = part?.trim() ?? '';
      if (text.isEmpty || RegExp(r'^[\d\s,.-]+$').hasMatch(text)) continue;
      final key = text.toLowerCase();
      if (!seen.add(key)) continue;
      useful.add(text);
    }
    return useful.join(', ');
  }

  Future<void> _searchPlaces(String raw) async {
    final query = raw.trim();
    if (query.length < 2) return;
    FocusScope.of(context).unfocus();
    setState(() => _searching = true);
    try {
      final hits = await _nominatimSearch(query);
      if (!mounted) return;
      if (hits.isEmpty) {
        setState(() => _searchHits = const []);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matching places found')),
        );
        return;
      }
      if (hits.length == 1) {
        await _selectSearchHit(hits.first);
        return;
      }
      setState(() => _searchHits = hits);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search failed. Check your connection.')),
      );
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _selectSearchHit(_SearchHit hit) async {
    _searchController.text = hit.title;
    setState(() => _searchHits = const []);
    await _applyLatLng(hit.point, moveMap: true);
  }

  Future<List<_SearchHit>> _nominatimSearch(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '5',
      'addressdetails': '1',
    });
    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'Buildmate24x7CustomerApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Search failed');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return const [];
    final hits = <_SearchHit>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final lat = double.tryParse('${item['lat']}');
      final lon = double.tryParse('${item['lon']}');
      if (lat == null || lon == null) continue;
      final display = item['display_name']?.toString().trim() ?? '';
      if (display.isEmpty) continue;
      final parts = display.split(',');
      hits.add(
        _SearchHit(
          title: parts.first.trim(),
          subtitle: parts.skip(1).take(2).join(',').trim(),
          point: LatLng(lat, lon),
        ),
      );
    }
    return hits;
  }

  _PickedPlace _fallbackPlace(LatLng point) {
    return _PickedPlace(
      '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
      'Dropped pin',
    );
  }

  void _onMapMoved(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 450), () {
      _applyLatLng(camera.center, moveMap: false);
    });
  }

  void _continue() {
    if (widget.isLocationUpdate) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushNamed(
      AppRoutes.chooseProfession,
      arguments: widget.args,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // Top half: real map surface.
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 13,
                    onPositionChanged: _onMapMoved,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                      userAgentPackageName: 'com.example.customerapp',
                      maxNativeZoom: 19,
                    ),
                    RichAttributionWidget(
                      attributions: const [
                        TextSourceAttribution(
                          'Esri, Maxar, Earthstar Geographics',
                        ),
                      ],
                    ),
                  ],
                ),

                // Back button, same style used across the auth flow.
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space5,
                      AppSpacing.space2,
                      AppSpacing.space5,
                      0,
                    ),
                    child: Row(
                      children: [
                        _RoundIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // Centered pin, fixed over the map (map pans beneath it).
                Center(
                  child: AnimatedBuilder(
                    animation: _pinController,
                    builder: (context, child) {
                      final bounce = _locating
                          ? math.sin(_pinController.value * math.pi) * -14
                          : 0.0;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: Offset(0, bounce),
                            child: child,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 10,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                    child: const _MapPin(),
                  ),
                ),

                // Locate-me FAB.
                Positioned(
                  right: AppSpacing.space5,
                  bottom: AppSpacing.space5,
                  child: _LocateMeButton(
                    loading: _locating,
                    onTap: _useCurrentLocation,
                  ),
                ),
              ],
            ),
          ),

          // Bottom half: search + location name + confirm button.
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.52,
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space5,
              AppSpacing.space5,
              AppSpacing.space5,
              0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pin your location',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'Drag the map or search to place the pin '
                      'exactly where you\'d like deliveries and '
                      'site visits.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    _SearchField(
                      controller: _searchController,
                      searching: _searching,
                      onSubmit: _searchPlaces,
                    ),
                    if (_searchHits.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space2),
                      _SearchResults(
                        hits: _searchHits,
                        onSelected: _selectSearchHit,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.space4),
                    _AddressCard(
                      located: _located,
                      locating: _locating,
                      place: _place,
                      onUseLocation: _useCurrentLocation,
                      onContinue: _continue,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 14, color: AppColors.onSurface),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.searching,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool searching;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: LoginFlowColors.accent),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmit,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search area, street or landmark',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (searching)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LoginFlowColors.accent,
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.hits,
    required this.onSelected,
  });

  final List<_SearchHit> hits;
  final ValueChanged<_SearchHit> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          for (var i = 0; i < hits.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              dense: true,
              leading: const Icon(
                Icons.place_outlined,
                color: LoginFlowColors.accent,
              ),
              title: Text(
                hits[i].title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              subtitle: hits[i].subtitle.isEmpty
                  ? null
                  : Text(
                      hits[i].subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () => onSelected(hits[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LoginFlowColors.accent.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            top: 4,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: LoginFlowColors.accentGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: LoginFlowColors.accent.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocateMeButton extends StatelessWidget {
  const _LocateMeButton({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: LoginFlowColors.accent,
                ),
              )
            : const Icon(
                Icons.my_location_rounded,
                color: LoginFlowColors.accent,
              ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.located,
    required this.locating,
    required this.place,
    required this.onUseLocation,
    required this.onContinue,
  });

  final bool located;
  final bool locating;
  final _PickedPlace? place;
  final VoidCallback onUseLocation;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: located && place != null
                ? Row(
                    key: const ValueKey('located'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: LoginFlowColors.accentMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: LoginFlowColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Current location',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: LoginFlowColors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: LoginFlowColors.accent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              place!.line1,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              place!.line2,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : InkWell(
                    key: const ValueKey('cta'),
                    onTap: onUseLocation,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space2,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: LoginFlowColors.accentMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: locating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: LoginFlowColors.accent,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.my_location_rounded,
                                      color: LoginFlowColors.accent,
                                      size: 18,
                                    ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  locating
                                      ? 'Finding your location…'
                                      : 'Use my current location',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Or drag the pin to fine-tune it manually',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.space4),
          LoginFlowContinueButton(
            label: 'Confirm & continue',
            enabled: located,
            onPressed: onContinue,
          ),
      ],
    );
  }
}
