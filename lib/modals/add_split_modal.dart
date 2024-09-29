// Required imports
// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_to_list_in_spreads, prefer_final_fields, library_private_types_in_public_api, unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

class AddSplitModal extends StatefulWidget {
  const AddSplitModal({super.key});

  @override
  _AddSplitModalState createState() => _AddSplitModalState();
}

class _AddSplitModalState extends State<AddSplitModal> {
  double _totalAmount = 0.0;
  String _paidByUserId = '';
  String _paidByUserName = 'Select User';
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _contacts = [];

  final TextEditingController _amountController = TextEditingController();
  final String _userId = '66bc64aa9eef5c744dfe0c93'; // Current user ID

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  // Function to fetch contacts (requires permission)
  Future<void> _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.map((contact) {
          return {
            'name': contact.displayName ?? '',
            'id': contact.identifier ?? '',
            'phones': contact.phones?.map((item) => item.value).toList() ?? []
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access contacts denied')),
      );
    }
  }

  // Function to add the split
  Future<void> _saveSplit() async {
    if (_paidByUserId.isEmpty || _totalAmount <= 0 || _participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/add/newSplit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'creator': _userId,
          'totalAmount': _totalAmount,
          'participants': _participants.map((participant) {
            return {
              'user': participant['id'],
              'splitAmount': participant['amount'],
              'paid': false
            };
          }).toList(),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Split added successfully')),
        );
        Navigator.of(context).pop();  // Close modal
      } else {
        throw Exception('Failed to add split');
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add split')),
      );
    }
  }

  // Function to handle user selection for "Who paid"
  void _onPaidByUserChanged(String? userId, String? userName) {
    setState(() {
      _paidByUserId = userId!;
      _paidByUserName = userName!;
    });
  }

  // Function to handle adding participants from contacts
  void _onAddParticipant(Map<String, dynamic> contact) {
    setState(() {
      _participants.add({
        'id': contact['id'],
        'name': contact['name'],
        'amount': _totalAmount / (_participants.length + 1)
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaveButtonEnabled = _totalAmount > 0 && _paidByUserId.isNotEmpty && _participants.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.black,
            ],
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Add Split',
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Total Amount
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Total Amount',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  _totalAmount = double.tryParse(value) ?? 0.0;
                }),
              ),
              const SizedBox(height: 12),

              // Who Paid Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Who Paid?',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                dropdownColor: Colors.black,
                value: _paidByUserId.isNotEmpty ? _paidByUserId : null,
                items: _contacts.map((contact) {
                  return DropdownMenuItem<String>(
                    value: contact['id'],
                    child: Text(contact['name']!,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  final selectedContact = _contacts.firstWhere((contact) => contact['id'] == value);
                  _onPaidByUserChanged(selectedContact['id'], selectedContact['name']);
                },
              ),
              const SizedBox(height: 12),

              // Add Participants from Contacts
              Column(
                children: [
                  const Text(
                    'Add Participants:',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ..._contacts.map((contact) {
                    return ListTile(
                      title: Text(contact['name']!, style: const TextStyle(color: Colors.white)),
                      trailing: ElevatedButton(
                        onPressed: () => _onAddParticipant(contact),
                        child: const Text('Add'),
                      ),
                    );
                  }).toList(),
                ],
              ),

              const SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: isSaveButtonEnabled ? _saveSplit : null,
                child: const Text('Save Split'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
