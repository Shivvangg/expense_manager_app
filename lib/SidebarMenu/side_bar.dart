// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unnecessary_to_list_in_spreads, prefer_const_declarations, unused_import

//flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; 

//project files
import '../../../utils/rive_utils.dart';
import '../models/sidebar_component/menu.dart';
import 'info_card.dart';
import 'side_menu.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late Future<String> _nameFuture;
  late Future<String> _emailFuture;
  Menu? selectedSideMenu; // Change to nullable Menu

  @override
  void initState() {
    super.initState();
    _nameFuture = getName();
    _emailFuture = getEmail();
    // Initialize selectedSideMenu based on the current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedSideMenu = sidebarMenus.firstWhere(
          (menu) => menu.route == ModalRoute.of(context)?.settings.name,
          orElse: () => sidebarMenus.first,
        );
      });
    });
  }

  Future<String> getName() async {
    // final companyProvider = Provider.of<CompanyProvider>(context, listen: false);
    // await companyProvider.loadCompanyData();
    // final companyName = companyProvider.companyData?.companyName ?? 'Shivang Pande';
    final companyName = 'Shivang Pande';
    return companyName;
  }

  Future<String> getEmail() async {
    // final companyProvider = Provider.of<CompanyProvider>(context, listen: false);
    // await companyProvider.loadCompanyData();
    // final companyEmail = companyProvider.companyData?.email ?? 'pandeshivang2308@gmail.com';
    final companyEmail = 'pandeshivang2308@gmail.com';
    return companyEmail;
  }

  void navigateTo(String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
    setState(() {
      selectedSideMenu = sidebarMenus.firstWhere((menu) => menu.route == routeName);
    });
  }

  Future<void> logout() async {
    final FlutterSecureStorage _storage = const FlutterSecureStorage();
    await _storage.delete(key: 'company');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF17203A),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: FutureBuilder<String>(
            future: _nameFuture,
            builder: (context, nameSnapshot) {
              final name = nameSnapshot.data ?? 'Shivang Pande';

              return FutureBuilder<String>(
                future: _emailFuture,
                builder: (context, emailSnapshot) {
                  final email = emailSnapshot.data ?? 'pandeshivang2308@gmail.com';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoCard(
                        name: name,
                        bio: email,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                        child: Text(
                          "MENU".toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.white70),
                        ),
                      ),
                      ...sidebarMenus.map((menu) {
                        return SideMenu(
                          menu: menu,
                          selectedMenu: selectedSideMenu,
                          press: () {
                            setState(() {
                              selectedSideMenu = menu;
                            });
                            navigateTo(menu.route); // Navigate to the menu's route
                          },
                          riveOnInit: (artboard) {
                            menu.rive.status = RiveUtils.getRiveInput(
                              artboard,
                              stateMachineName: menu.rive.stateMachineName,
                            );
                            // Start animation immediately if selected
                            if (selectedSideMenu == menu) {
                              RiveUtils.chnageSMIBoolState(menu.rive.status!);
                              menu.rive.status!.value = true;
                            }
                          },
                        );
                      }).toList(),
                      const Spacer(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: const Text('Logout', style: TextStyle(color: Colors.white)),
                        onTap: logout,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
