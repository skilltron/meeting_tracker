# Meeting Tracker

A cross-platform meeting tracker application with adaptive UI, calendar integration, and ADHD-friendly features.

## Features

### Core Functionality
- **Meeting Timer**: Track meeting duration with start/stop/reset controls
- **Calendar Integration**: Sync with Google Calendar, Outlook, and OneDrive
- **Meeting Scheduler**: Create and schedule meetings directly from the app

### ADHD-Friendly Features
- **Adaptive Layout**: UI adapts based on your usage patterns
- **Breathing Exercise**: Guided breathing with customizable timing
- **Social Tips**: ADHD-friendly social interaction tips with mnemonics
- **Quick Notes**: Minimal notepad for quick thoughts
- **Visual Alerts**: Configurable visual and audio alerts for upcoming meetings
- **Ghost Mode**: Transparent overlay mode that stays on top

### Smart Features
- **Usage Learning**: Tracks your patterns and adapts the interface
- **Predictive Display**: Shows features you're likely to need before you need them
- **Time-Based Patterns**: Learns your hourly and daily usage patterns
- **Auto-Adaptation**: Layout automatically adjusts as you use the app

## Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Platform-specific dependencies (see below)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/biochem/meeting_tracker.git
cd meeting_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API credentials:
   - Google Calendar: See `SETUP.md` for OAuth setup
   - Microsoft/Outlook: See `OUTLOOK_SETUP.md` for Azure app registration

4. Run the app:
```bash
flutter run
```

## Building

### macOS
```bash
flutter build macos
```

### Windows
```bash
flutter build windows
```

### Linux
```bash
flutter build linux
```

## Architecture

### Providers
- `MeetingProvider`: Manages meeting timer state
- `CalendarProvider`: Handles calendar sync and events
- `UIProvider`: Manages UI state (opacity, alerts, docking)
- `UsageTrackerProvider`: Tracks usage patterns for adaptive UI
- `LayoutProvider`: Manages adaptive layout configuration
- `BreathingProvider`: Manages breathing exercise state
- `SocialTipsProvider`: Manages social tips selection and shuffling
- `NotesProvider`: Manages quick notes
- `TodoProvider`: Manages meeting to-do items

### Adaptive Layout System
The app uses a minimal ML approach to learn user patterns:
- Tracks feature usage frequency and recency
- Learns hourly and daily usage patterns
- Calculates priority scores for features
- Automatically adjusts layout (compact/balanced/expanded)
- Predicts likely-needed features based on time patterns

## Privacy

All data is stored locally:
- Usage patterns stored in SharedPreferences
- Calendar data cached locally
- No external ML services
- No data sent to third parties

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]
