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
  List<Contact> _contacts = [];
  bool _isLoadingContacts = true;

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
        _contacts = contacts.toList();
        _isLoadingContacts = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access contacts denied')),
      );
      setState(() {
        _isLoadingContacts = false;
      });
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
        Uri.parse('http://192.168.1.8:8000/add/newSplit'),
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
        Navigator.of(context).pop(); // Close modal
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

  // Function to handle adding participants from contacts
  void _onAddParticipant(Contact contact) {
    setState(() {
      _participants.add({
        'id': contact.identifier ?? '',
        'name': contact.displayName ?? '',
        'amount': _totalAmount / (_participants.length + 1)
      });
    });
  }

  // Open contact selection modal
  void _openContactSelectionModal() async {
    Contact? contact = await showDialog<Contact>(
      context: context,
      builder: (BuildContext context) => ContactSelectionModal(
        contacts: _contacts,
      ),
    );

    if (contact != null) {
      _onAddParticipant(contact);
    }
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

              // Who Paid Dropdown (Currently just placeholder, can be expanded with similar contact fetching)
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
                    value: contact.identifier,
                    child: Text(contact.displayName ?? '', style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  final selectedContact = _contacts.firstWhere((contact) => contact.identifier == value);
                  setState(() {
                    _paidByUserId = selectedContact.identifier ?? '';
                    _paidByUserName = selectedContact.displayName ?? '';
                  });
                },
              ),
              const SizedBox(height: 12),

              // Add Participants Button
              ElevatedButton(
                onPressed: _openContactSelectionModal,
                child: const Text('Add Participant from Contacts'),
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

// Modal to select contacts
class ContactSelectionModal extends StatelessWidget {
  final List<Contact> contacts;

  const ContactSelectionModal({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: contacts.isEmpty
          ? const Center(child: Text('No contacts found'))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  onTap: () => Navigator.pop(context, contact),
                );
              },
            ),
    );
  }
}
