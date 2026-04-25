# Flutter Analyze Fixes TODO

## Step 1: Fix theme_config.dart
- [ ] Add const to BoxShadow, LinearGradient, IconThemeData, GoogleFonts.inter

## Step 2: Fix auth_provider.dart
- [ ] prefer_conditional_assignment at line 68

## Step 3: Fix admin_dashboard_screen.dart
- [ ] use_build_context_synchronously at lines 697, 707, 740, 748

## Step 4: Fix admin_manual_scanner_screen.dart
- [ ] prefer_const_constructors at lines 53, 202, 283
- [ ] unnecessary_null_comparison at line 319

## Step 5: Fix admin_overview_screen.dart
- [ ] prefer_const_constructors at line 189
- [ ] prefer_const_literals_to_create_immutables at line 190
- [ ] prefer_const_constructors at line 190
- [ ] deprecated_member_use (withOpacity -> withValues) at lines 197, 208, 234

## Step 6: Fix admin_scanner_screen.dart
- [ ] prefer_const_constructors at lines 137, 139, 145, 147, 183, 218, 221, 225
- [ ] prefer_const_literals_to_create_immutables at line 138

## Step 7: Fix admin_settings_screen.dart
- [ ] use_build_context_synchronously at lines 137, 301, 337, 345, 393

## Step 8: Fix admin_students_inside_screen.dart
- [ ] use_build_context_synchronously at line 446

## Step 9: Fix admin_students_screen.dart
- [ ] prefer_const_constructors at lines 184, 323
- [ ] use_build_context_synchronously at lines 266, 274, 307, 315

## Step 10: Fix login_screen.dart
- [ ] prefer_const_constructors at lines 70, 71, 88, 89, 385, 390

## Step 11: Fix student_profile_screen.dart
- [ ] prefer_const_constructors at lines 181, 278, 280

## Step 12: Fix supabase_service.dart
- [ ] prefer_const_declarations at line 485

## Step 13: Fix custom_dialogs.dart
- [ ] prefer_const_constructors at line 252

## Step 14: Fix loading_skeleton.dart
- [ ] prefer_const_constructors at lines 34, 35, 97, 99, 101

## Step 15: Fix seat_map_widget.dart
- [ ] deprecated_member_use (withOpacity -> withValues) at lines 42, 149, 165, 270
- [ ] unnecessary_to_list_in_spreads at lines 215, 240

## Verification
- [ ] Run flutter analyze to confirm 0 issues

