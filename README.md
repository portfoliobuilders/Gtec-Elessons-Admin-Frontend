# G-TEC Admin Console — Flutter

Pixel-perfect Flutter recreation of the **G-TEC Education · Admin Console** web design (all 11 screens). Layout, colors, typography, spacing, icons, borders, shadows, card styles, navigation flow and component positions are preserved 1:1 from the source design; nothing was redesigned.

## Requirements

- Flutter **3.27+** (uses `CardThemeData` / `DialogThemeData`)
- Dart 3.3+

## Run

```bash
flutter pub get
flutter run -d chrome        # or any device: android / ios / windows / macos
```

The app opens on the Dashboard. Every sidebar item that has a screen navigates to it (cross-fade transition), exactly mirroring the design's screen flow.

## Screens (11)

| # | Screen | Route |
|---|--------|-------|
| 01 | Analytics Dashboard | `/dashboard` |
| 02 | Curriculum Builder (CMS) | `/curriculum` |
| 03 | Pricing Manager (INR vs GCC) | `/pricing` |
| 04 | Assessment Engine (mock test) | `/assessments` |
| 05 | Team & Roles (Super Admin) | `/team` |
| 06 | Teacher Console (tutor role) | `/teacher` |
| 07 | Student Management | `/students` |
| 08 | Live Class Scheduler | `/live-classes` |
| 09 | Notifications / Broadcast | `/notifications` |
| 10 | Payments & Leads | `/payments` |
| 11 | Growth & Insights | `/growth` |

## Architecture (MVC)

```
lib/
├── core/
│   ├── constants/      app_colors, app_sizes, app_icons (verbatim design SVGs)
│   ├── theme/          app_theme (ThemeData), app_text_styles
│   ├── utils/          responsive (breakpoints)
│   ├── widgets/        app_card, app_buttons, app_inputs, status_badge,
│   │                   hatch_avatar, grid_table, charts
│   └── services/       (reserved for API layer)
├── models/             plain data classes, one per entity
├── controllers/        ChangeNotifier per screen (Provider), holds all data
├── views/
│   ├── layouts/        admin_shell (sidebar + top bar + content)
│   ├── widgets/        app_sidebar, app_top_bar, nav_presets, shared_widgets
│   └── screens/        11 screens
├── routes/             app_routes, app_router
└── main.dart
```

## Design system mapping

- **Fonts** — Plus Jakarta Sans 400–800 + JetBrains Mono (monograms), via `google_fonts`.
- **Colors** — every hex from the design lives in `core/constants/app_colors.dart`; no other colors are used.
- **Icons** — the design's hand-drawn stroke SVGs are copied verbatim into `app_icons.dart` and rendered with `flutter_svg` (identical stroke weights: 1.8 default, 2.2 buttons, 2.4–2.6 checks).
- **Shadows** — card `0 10px 24px -18px rgba(20,26,42,.35)` and CTA glows are in `AppTheme`.
- **Hatched avatars** — the `repeating-linear-gradient(135deg …)` placeholders are reproduced with a `CustomPainter` (`HatchAvatar` / `HatchBox`).
- **Charts** — stacked bars, donut (conic-gradient equivalent) and funnel are custom-painted with light `TweenAnimationBuilder` entrance animations.
- **Tables** — `GridRow` mirrors the design's CSS `grid-template-columns` fr units.

## Responsiveness

The source design targets a 1440px desktop canvas. Proportions are preserved on desktop; below **1100px** the sidebar collapses into a drawer, KPI grids reflow 4 → 2 → 1, split panes stack, and wide tables scroll horizontally. No fixed page widths are used — everything is `Expanded`/`Flexible`/`Wrap`/`LayoutBuilder` based.

## Wiring a backend

Controllers hold the design's data as plain Dart lists. To connect an API, add a service in `core/services/`, inject it into the controller, and replace the constant lists with fetched state — views need no changes.
