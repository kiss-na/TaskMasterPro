import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPicker extends StatelessWidget {
  final Function(String, String) onContactPicked;

  const ContactPicker({
    Key? key,
    required this.onContactPicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.contacts),
        label: const Text('Pick from Contacts'),
        onPressed: () => _pickContact(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _pickContact(BuildContext context) async {
    final permissionStatus = await Permission.contacts.request();
    
    if (permissionStatus.isGranted) {
      try {
        final Contact? contact = await ContactsService.openDeviceContactPicker();
        
        if (contact != null) {
          final name = contact.displayName ?? '';
          String phone = '';
          
          if (contact.phones != null && contact.phones!.isNotEmpty) {
            phone = contact.phones!.first.value ?? '';
          }
          
          if (name.isNotEmpty) {
            onContactPicked(name, phone);
          } else {
            _showErrorDialog(context, 'The selected contact has no name');
          }
        }
      } catch (e) {
        _showErrorDialog(context, 'Error picking contact: $e');
      }
    } else {
      _showErrorDialog(
        context,
        'Permission to access contacts was denied. Please enable it in app settings.',
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Picker Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
