import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// NOTE: Zone management is disabled for MVP release with single delivery person
/*
class ZonesScreen extends StatefulWidget {
  const ZonesScreen({super.key});

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  List<Zone> _zones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _zones = [
          Zone(
            id: '1',
            name: 'Downtown Area',
            description: 'Central business district and surrounding areas',
            city: 'Mumbai',
            state: 'Maharashtra',
            country: 'India',
            pincodes: ['400001', '400002', '400003'],
            areas: ['Fort', 'Colaba', 'Nariman Point'],
            isActive: true,
            isDefault: true,
            deliveryFee: 50.0,
            minimumOrderAmount: 200.0,
            maximumOrderAmount: 5000.0,
            estimatedDeliveryTime: 30,
            createdAt: DateTime.now(),
          ),
          Zone(
            id: '2',
            name: 'Suburban Area',
            description: 'Residential and commercial areas in the suburbs',
            city: 'Mumbai',
            state: 'Maharashtra',
            country: 'India',
            pincodes: ['400101', '400102', '400103'],
            areas: ['Andheri', 'Bandra', 'Khar'],
            isActive: true,
            isDefault: false,
            deliveryFee: 75.0,
            minimumOrderAmount: 300.0,
            maximumOrderAmount: 8000.0,
            estimatedDeliveryTime: 45,
            createdAt: DateTime.now(),
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load zones'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleZoneStatus(Zone zone) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _zones = _zones.map((z) {
          if (z.id == zone.id) {
            return z.copyWith(isActive: !z.isActive);
          }
          return z;
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update zone status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Zones'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _zones.isEmpty
              ? const CustomEmptyWidget(
                  message: 'No delivery zones available',
                  icon: Icons.map_outlined,
                  showActionButton: false,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _zones.length,
                  itemBuilder: (context, index) {
                    final zone = _zones[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        title: Text(
                          zone.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(zone.description),
                            const SizedBox(height: 4),
                            Text('Location: ${zone.formattedLocation}'),
                            Text('Areas: ${zone.formattedAreas}'),
                            Text('Pincodes: ${zone.formattedPincodes}'),
                            if (zone.deliveryFee != null)
                              Text(
                                  'Delivery Fee: ${zone.formattedDeliveryFee}'),
                            if (zone.minimumOrderAmount != null)
                              Text(
                                  'Min Order: ${zone.formattedMinimumOrderAmount}'),
                            if (zone.maximumOrderAmount != null)
                              Text(
                                  'Max Order: ${zone.formattedMaximumOrderAmount}'),
                            if (zone.estimatedDeliveryTime != null)
                              Text(
                                  'Est. Time: ${zone.formattedEstimatedDeliveryTime}'),
                            Text(
                              'Status: ${zone.statusText}',
                              style: TextStyle(
                                color: Color(int.parse(
                                    zone.statusColor.replaceAll('#', '0xFF'))),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Switch(
                          value: zone.isActive,
                          onChanged: (value) => _toggleZoneStatus(zone),
                          activeColor: AppColors.primary,
                        ),
                        onTap: () {
                          // TODO: Navigate to zone details
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddZoneScreen()),
          );
          if (result == true) {
            _loadZones();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
*/

// MVP replacement for ZonesScreen
class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Area'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 80,
                color: AppColors.primary,
              ),
              SizedBox(height: 20),
              Text(
                'Single Delivery Zone Mode',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'For this MVP release, you are assigned to the entire delivery area.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
