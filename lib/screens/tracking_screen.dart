import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  // Xin quyền Location và lấy vị trí hiện tại
  Future<void> _loadCurrentLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Vui lòng bật GPS (dịch vụ vị trí) trên thiết bị.';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw 'Bạn đã từ chối quyền truy cập vị trí.';
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Quyền vị trí bị chặn. Hãy bật lại trong Cài đặt.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _currentPosition = latLng;
        _loading = false;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theo dõi chạy bộ')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _currentPosition == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Không lấy được vị trí.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCurrentLocation,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 16),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: {
        Marker(
          markerId: const MarkerId('current'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
        ),
      },
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}