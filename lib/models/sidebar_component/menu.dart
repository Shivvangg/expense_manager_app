import 'rive_model.dart';

class Menu {
  final String title;
  final RiveModel rive;
  final String route;

  Menu({required this.title, required this.rive, required this.route});
}

List<Menu> sidebarMenus = [
  // Menu(
  //   title: "Home",
  //   rive: RiveModel(
  //       src: "assets/RiveAssets/icons.riv",
  //       artboard: "HOME",
  //       stateMachineName: "HOME_interactivity",),
  //   route: '/home'
  // ),
  
  Menu(
    title: "Expenses",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "LIKE/STAR",
        stateMachineName: "STAR_Interactivity"),
    route: '/',
  ),
  Menu(
    title: "My Splits",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "LIKE/STAR",
        stateMachineName: "STAR_Interactivity"),
    route: '/suggested-certificates',
  ),
  Menu(
    title: "Search Expenses",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "SEARCH",
        stateMachineName: "SEARCH_Interactivity"),
    route: '/searchExpense',
  ),
  Menu(
    title: "My Profile",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "USER",
        stateMachineName: "USER_Interactivity"),
    route: '/myProfile',
  ),
];
// List<Menu> sidebarMenus2 = [
//   Menu(
//     title: "History",
//     rive: RiveModel(
//         src: "assets/RiveAssets/icons.riv",
//         artboard: "TIMER",
//         stateMachineName: "TIMER_Interactivity"),
//   ),
//   Menu(
//     title: "Notifications",
//     rive: RiveModel(
//         src: "assets/RiveAssets/icons.riv",
//         artboard: "BELL",
//         stateMachineName: "BELL_Interactivity"),
//   ),
//   Menu(
//     title: "Company Profile",
//     rive: RiveModel(
//         src: "assets/RiveAssets/icons.riv",
//         artboard: "USER",
//         stateMachineName: "USER_Interactivity"),
//   ),
// ];

