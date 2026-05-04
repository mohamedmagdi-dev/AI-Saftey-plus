# PROJECT: AI Safety+ (Refactor & Logic Injection)

## 1. OBJECTIVE
Refactor the current "Wall of Code" UI into **Reusable Widgets** and implement **BLoC/Cubit** state management. Prepare the architecture for real API integration.

## 2. REFACTORING STRATEGY (Atomic UI)
The agent must extract repeated UI elements from the large screen files into `lib/core/widgets/`:

- **Atoms:** `GlassContainer`, `NeonButton`, `CustomTextField`, `StatusIndicator`.
- **Molecules:** `CameraCard`, `AlertTile`, `StatCard`, `GlassBottomNav`.
- **Cleanliness Rule:** No Screen file should exceed 300 lines. Logic must be moved to Cubits.

## 3. LOGIC LAYER (BLoC/Cubit)
Create the following Cubits to handle state. Use `equatable` for states.

- **AuthCubit:** Handle Login, Register, Logout, and Token persistence.
- **CameraCubit:** Handle fetching camera lists and stream status.
- **AlertCubit:** Handle real-time alert logs and history filtering.
- **NavigationCubit:** Manage BottomNavBar index switching.

## 4. DATA LAYER PREPARATION (API Ready)
Prepare the `Data` and `Domain` layers for the upcoming API:
1.  **Entities:** Create pure Dart classes in `domain/entities` (e.g., `CameraEntity`, `AlertEntity`).
2.  **Models:** Create `domain/models` with `fromJson` factories.
3.  **Repositories:** Define abstract classes in `domain/repositories`.
4.  **DataSources:** Create `RemoteDataSource` templates using `Dio`.

## 5. SPECIFIC UI CLEANUP
- **Live Stream:** Implement a `CustomPainter` for the bounding boxes so they can be updated dynamically via state, rather than being hardcoded.
- **Charts:** Move `fl_chart` configurations into dedicated wrapper widgets in `features/reports/presentation/widgets/`.

## 6. INTERACTIVE ELEMENTS
- Replace all `onTap: (){}` with BLoC events/methods.
- Implement `GoRouter` navigation calls within the UI or via a Navigation helper.
- Ensure "Gold Pill" buttons show a `CircularProgressIndicator` when `state is Loading`.

## EXECUTION STEP
1. Scan the current large screen files.
2. Identify and extract all "Glassmorphism" and "Neon" styles into reusable theme-based widgets.
3. Implement the BLoC providers in `main.dart`.
4. Update the screens to use `BlocBuilder` or `context.read<Cubit>()` for all button actions.