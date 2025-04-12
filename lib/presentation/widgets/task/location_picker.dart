import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPicker extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final Function(double, double, String?) onLocationPicked;

  const LocationPicker({
    Key? key,
    this.latitude,
    this.longitude,
    required this.onLocationPicked,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isMapReady = false;
  String? _locationName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null && widget.longitude != null) {
      _selectedLocation = LatLng(widget.latitude!, widget.longitude!);
    }
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _selectedLocation ??= LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      
      if (_mapController != null && _isMapReady) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location: $e')),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  Future<void> _getLocationName(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = [
          place.name,
          place.street,
          place.locality,
          place.postalCode,
          place.country,
        ]
            .where((element) => element != null && element.isNotEmpty)
            .join(', ');
        
        setState(() {
          _locationName = name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location name: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('My Location'),
              onPressed: () => _requestLocationPermission(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.pin_drop),
              label: const Text('Pick on Map'),
              onPressed: () => _showMapPicker(context),
            ),
          ],
        ),
        if (_selectedLocation != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Location:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                ),
                Text(
                  'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                ),
                if (_locationName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Address: $_locationName',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showMapPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation ?? const LatLng(0, 0),
                        zoom: _selectedLocation != null ? 15 : 2,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        setState(() {
                          _isMapReady = true;
                        });
                        
                        if (_selectedLocation != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                          );
                        }
                      },
                      onTap: (position) {
                        setState(() {
                          _selectedLocation = position;
                        });
                        _getLocationName(position);
                      },
                      markers: _selectedLocation != null
                          ? {
                              Marker(
                                markerId: const MarkerId('selected_location'),
                                position: _selectedLocation!,
                              ),
                            }
                          : {},
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                    ),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedLocation != null
                        ? () {
                            widget.onLocationPicked(
                              _selectedLocation!.latitude,
                              _selectedLocation!.longitude,
                              _locationName,
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('Select This Location'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
