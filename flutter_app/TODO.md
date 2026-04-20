# Fix Supabase Students Table 'updated_at' Column Error (PGRST204)

## Steps:

### 1. [DB ADMIN] Add missing column to Supabase (User executes)
```
Run in Supabase Dashboard > SQL Editor:
ALTER TABLE public.students ADD COLUMN updated_at timestamptz DEFAULT now() NOT NULL;
```
- Refresh schema cache: Dashboard > API > Settings > Refresh RPC/Schema cache
- Optional: Verify RLS policies enabled for 'students' table
- Test: Manual query `select * from students where id=eq.21510014144;`

### 2. [CODE] Update supabase_service.dart for robustness\n- Remove explicit `updated_at` sets in UPDATEs (use DB default)\n- ✅ **COMPLETED**: Removed from 5 locations (upsertStudent, processScan, resetSystem, addStudent, updateStudentName)

### 3. [TEST] Verify fix
```
cd flutter_app
flutter clean
flutter pub get
flutter run
```
- Test scan ID: 21510014144 → No PGRST204 error
- Check: Students inside list, scan logs, real-time updates

### 4. [COMPLETE] Mark done
- Remove this TODO.md or mark [x]

**Status: AWAITING DB FIX → Code edit → Test**

