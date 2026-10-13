# Study Clock (Smart Study • Better Future)

Production-quality Flutter mobile application for tracking and analyzing student study time with offline-first local storage, sensor-assisted study modes, and ClassMaster ecosystem integration.

## Key Features

- **Intuitive Stopwatch Engine**: Accurate timestamp-based session tracking with pause, resume, and real-time state persistence.
- **3 Dynamic Study Modes**:
  1. **Manual Mode**: Classic start, pause, and stop controls.
  2. **Face-up ON / Face-down OFF**: Screen straight on table = studying (always awake); flipped face down = paused.
  3. **Flip to ON / Screen OFF**: Flipped face down on desk = studying (screen dims/sleeps); picked up face up = paused.
- **Rich Analytics & Insights**:
  - 30-Day study total, daily average, and session count.
  - Interactive 30-day study bar chart.
  - Best and lowest study day highlights.
  - Detailed time-of-day distribution (6 AM – 12 AM breakdown).
  - 30-Day study intensity heatmap.
- **History & Session Logs**:
  - Monthly calendar browsing.
  - Expandable session breakdowns with start/end timestamps and study mode records.
- **Daily Motivation**:
  - Deterministic daily authentic Quran verses, Hadiths, and discipline quotes in Bengali with proper scholarly references.
- **ClassMaster Integration & Backup**:
  - Cloud sync adapter for ClassMaster accounts.
  - Full offline data export and restore via JSON.

## Design System

Built on the **ClassMaster Design System**:
- **Palette**: Dark Navy (`#0F172A`), Surface (`#111827`), Surface Variant (`#1E293B`), Primary Royal Blue (`#2563EB`), Accent Indigo (`#4F46E5`), Success Green (`#16A34A`), Destructive Red (`#DC2626`).
- **Typography**: Inter (English) + Noto Sans Bengali.
- **Spacing & Shapes**: 8-point spacing grid with consistent corner radiuses.

## Architecture

Feature-first structure powered by **Flutter Riverpod (3.x)**, **GoRouter**, and **Hive**:

```
lib/
├── app/            # App config, routing, design tokens & theme
├── core/           # Sensor services, wakelock, notifications, utils
├── features/
│   ├── home/       # Home dashboard, daily goal, motivation
│   ├── stopwatch/  # Stopwatch dial, session controller & repo
│   ├── history/    # Monthly study history & session logs
│   ├── analytics/  # Analytics engine, charts, heatmap
│   ├── study_mode/ # 3 study modes & bottom sheet selector
│   ├── motivation/ # Daily authentic Hadith & Quran repo
│   ├── settings/   # App settings & preferences
│   ├── backup/     # Local JSON export/restore & cloud sync
│   └── classmaster/# ClassMaster auth & repository adapter
└── shared/         # Reusable widgets & brand components
```

## Getting Started

1. Ensure Flutter is installed:
   ```bash
   flutter --version
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

4. Run tests:
   ```bash
   flutter test
   ```
