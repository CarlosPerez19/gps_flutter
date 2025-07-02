import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class GeoPage extends StatefulWidget {
  const GeoPage({super.key});

  @override
  State<GeoPage> createState() => _GeoPageState();
}

class _GeoPageState extends State<GeoPage> {
  String _locationMessage = 'Ubicación no obtenida';
  String? _googleMapsUrl;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = 'Los servicios de ubicación están desactivados.';
        _googleMapsUrl = null;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = 'Permisos de ubicación denegados';
          _googleMapsUrl = null;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage =
            'Los permisos están permanentemente denegados, no podemos solicitar permisos.';
        _googleMapsUrl = null;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final lat = position.latitude;
    final lon = position.longitude;

    setState(() {
      _locationMessage = 'Latitud: $lat, Longitud: $lon';
      _googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    });
  }

  Future<void> _launchMapsUrl() async {
    if (_googleMapsUrl != null && await canLaunchUrl(Uri.parse(_googleMapsUrl!))) {
      await launchUrl(Uri.parse(_googleMapsUrl!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geolocalización')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_locationMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Obtener ubicación'),
            ),
            const SizedBox(height: 20),
            if (_googleMapsUrl != null)
              TextButton(
                onPressed: _launchMapsUrl,
                child: const Text('Ver en Google Maps'),
              ),
          ],
        ),
      ),
    );
  }
}
