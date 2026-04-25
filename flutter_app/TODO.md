# TODO: Fix "View Seat Map" Navigation

## Plan
- [x] Understand current code and identify issue
- [x] Create plan for fix
- [x] Edit `app_navigation.dart` to pass `onNavigateToTab` callback to `AdminOverviewScreen`
- [x] Edit `admin_overview_screen.dart` to accept callback and call it with index 3 on "View Seat Map" tap
- [x] Verify no `Navigator.push()` is used and existing navigation isn't broken

## Details
1. `app_navigation.dart`:
   - `_adminScreens[0]` is `AdminOverviewScreen`
   - Remove `const` from `AdminOverviewScreen()` constructor
   - Pass `onNavigateToTab: (index) => setState(() => _currentIndex = index)`

2. `admin_overview_screen.dart`:
   - Add `final Function(int)? onNavigateToTab;` field
   - Add to constructor: `const AdminOverviewScreen({super.key, this.onNavigateToTab});`
   - In `GestureDetector` onTap for "View Seat Map" card:
     ```dart
     onTap: () {
       widget.onNavigateToTab?.call(3);
     },
     ```
   - This switches to Seats tab (index 3) without pushing a new route.

