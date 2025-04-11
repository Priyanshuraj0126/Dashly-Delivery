import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/zone.dart';
import '../../widgets/custom_button.dart';

class AddZoneScreen extends StatefulWidget {
  const AddZoneScreen({super.key});

  @override
  State<AddZoneScreen> createState() => _AddZoneScreenState();
}

class _AddZoneScreenState extends State<AddZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxOrderController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  final List<String> _pincodes = [];
  final List<String> _areas = [];
  bool _isActive = true;
  bool _isDefault = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _deliveryFeeController.dispose();
    _minOrderController.dispose();
    _maxOrderController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final zone = Zone(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          description: _descriptionController.text,
          city: _cityController.text,
          state: _stateController.text,
          country: _countryController.text,
          pincodes: _pincodes,
          areas: _areas,
          isActive: _isActive,
          isDefault: _isDefault,
          deliveryFee: double.tryParse(_deliveryFeeController.text),
          minimumOrderAmount: double.tryParse(_minOrderController.text),
          maximumOrderAmount: double.tryParse(_maxOrderController.text),
          estimatedDeliveryTime: int.tryParse(_estimatedTimeController.text),
          createdAt: DateTime.now(),
        );

        // TODO: Save zone to backend
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create zone'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Zone'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Zone Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a zone name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a state';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _deliveryFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Fee (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _minOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Min Order (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Max Order (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _estimatedTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Est. Time (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Default Zone'),
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _isSubmitting ? () {} : () => _submitForm(),
                text: _isSubmitting ? 'Creating...' : 'Create Zone',
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
