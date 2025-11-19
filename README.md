# BashkirKeyboard

A custom iOS keyboard extension that extends the standard Russian Apple keyboard layout with Bashkir characters accessible via long-press popups.

## 📱 Project Overview

**BashkirKeyboard** is an iOS custom keyboard project that provides seamless access to Bashkir-specific characters while maintaining the familiar Russian keyboard layout. The keyboard uses the standard Russian Apple keyboard as its base and adds Bashkir letters through intuitive long-press popups.

### Key Components

- **Main Host App (SwiftUI)**: Provides settings interface and theme customization
- **Custom Keyboard Extension**: Full keyboard implementation with Bashkir character support
- **Shared Settings**: App Groups integration for syncing preferences between app and extension
- **Theme System**: Three beautiful themes including a preview of Liquid Glass (glassmorphism) for iOS 26

### Minimum Requirements

- **iOS 16.0+** deployment target
- **Xcode 15+**
- **Swift 5.9+**

## ✨ Features

### Full Russian Layout
Complete support for the standard Russian keyboard layout as provided by Apple, ensuring familiarity and ease of use.

### Long-Press Popups for Bashkir Characters
Access Bashkir-specific characters by long-pressing their Russian counterparts:

- **з** → **ҙ**
- **с** → **ҫ**
- **а** → **ә**
- **у** → **ү**
- **х** → **һ**
- **о** → **ө**
- **н** → **ң**
- **г** → **ғ**
- **к** → **ҡ**

### Theme System
Choose from three beautiful themes:

- **System**: Follows iOS system appearance (light/dark mode)
- **Classic**: Traditional keyboard styling
- **Liquid Glass**: Modern glassmorphism preview for iOS 26

### Additional Features

- 🎨 **Theme Switching**: Change themes from the main app, synced to keyboard via App Groups
- 📳 **Haptic Feedback**: Tactile response for key presses (configurable)
- 📱 **Auto Layout Support**: Optimized for all iPhone screen sizes
- 🌙 **Dark Mode**: Full support for iOS dark mode

## 📁 Project Structure

```
bashboard/
├── App/                          # Main application UI (SwiftUI)
│   ├── AppMain.swift            # App entry point
│   ├── Services/
│   │   └── SettingsStore.swift  # Settings management
│   └── Views/                   # SwiftUI views
│       ├── RootView.swift
│       ├── WelcomeView.swift
│       ├── SettingsView.swift
│       └── InstructionsView.swift
│
├── BashkirKeyboardExtension/    # Custom keyboard implementation
│   ├── KeyboardViewController.swift
│   ├── Info.plist
│   ├── Logic/                   # Keyboard logic
│   │   ├── HapticFeedbackManager.swift
│   │   ├── KeyboardInputHandler.swift
│   │   ├── LongPressHandler.swift
│   │   └── ThemeBridge.swift
│   ├── Model/                   # Data models
│   │   ├── KeyboardKey.swift
│   │   ├── KeyboardLayout.swift
│   │   ├── KeyboardRow.swift
│   │   └── AlternativeCharactersProvider.swift
│   └── Views/                   # UIKit views
│       ├── KeyboardView.swift
│       ├── KeyView.swift
│       └── PopupKeyView.swift
│
├── Shared/                      # Shared code between app and extension
│   ├── SharedSettings.swift     # App Group settings keys
│   └── Theme/                   # Theme system
│       ├── KeyboardTheme.swift
│       ├── ThemeManager.swift
│       └── ThemeTokens.swift
│
├── Tests/                       # Unit tests
│   └── AlternativeCharactersTests.swift
│
└── INSTRUCTIONS.md              # Developer notes and documentation
```

## 🔧 Prerequisites

Before setting up the project, ensure you have:

- **Xcode 15+** installed
- **iOS 16.0+** deployment target configured
- **Swift 5.9+** language version
- **Apple Developer Account** (for device testing and distribution)
- **App Group** capability enabled in your Apple Developer account

## 🚀 Setup Instructions

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd bashboard
```

### Step 2: Open the Project

Open `bashboard.xcodeproj` in Xcode.

### Step 3: Configure Deployment Target

Ensure both targets have the correct deployment target:

1. Select the project in the navigator
2. For each target (main app and keyboard extension):
   - Go to **General** tab
   - Set **iOS Deployment Target** to **16.0**

### Step 4: Configure App Groups

1. Select the main app target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** and add **App Groups**
4. Add your App Group identifier (e.g., `group.com.yourname.BashkirKeyboard`)
5. Repeat for the keyboard extension target with the **same** App Group identifier

> **Note**: Update `SharedAppGroup.identifier` in `Shared/SharedSettings.swift` to match your App Group identifier.

### Step 5: Configure Signing

1. Select each target
2. In **Signing & Capabilities**, choose your development team
3. Ensure both targets use the same team and bundle identifier prefix

### Step 6: Build the Project

1. Select the **main app target** (not the keyboard extension)
2. Build the project (⌘B) or run (⌘R)

> **Important**: Always build the main app target. The keyboard extension will be built automatically as a dependency.

## 🏃 Running the App

### On Simulator

1. Select a simulator (iPhone 14 or later recommended)
2. Run the app (⌘R)
3. The app will launch, but the keyboard extension must be enabled manually

### On Real Device

1. Connect your iOS device
2. Run the app (⌘R)
3. Enable the keyboard:
   - Go to **Settings** → **General** → **Keyboard** → **Keyboards**
   - Tap **Add New Keyboard**
   - Select **BashkirKeyboard**
   - Tap **BashkirKeyboard** in the list
   - Enable **Allow Full Access** (required for theme syncing)

### Switching Keyboards

- Tap and hold the **🌐** globe icon in the keyboard
- Select **BashkirKeyboard** from the list
- Or tap the globe icon to cycle through enabled keyboards

## 🧪 Testing Bashkir Characters

To test the long-press functionality:

1. Open any text input field (Notes app, Messages, etc.)
2. Switch to **BashkirKeyboard**
3. Long-press any of these Russian keys to see Bashkir alternatives:
   - **а** → **ә**
   - **о** → **ө**
   - **г** → **ғ**
   - **к** → **ҡ**
   - **н** → **ң**
   - **х** → **һ**
   - **у** → **ү**
   - **с** → **ҫ**
   - **з** → **ҙ**

4. Slide your finger to the desired character and release to insert it

## 📦 Building for Release

### Archive Preparation

1. Ensure both targets have matching signing:
   - Main app target: **Automatically manage signing** or manual provisioning profile
   - Keyboard extension target: Same team and matching provisioning profile

2. Select **Any iOS Device** or a connected device (not simulator)

3. Go to **Product** → **Archive**

4. Once archived:
   - The keyboard extension is automatically included
   - Both targets are packaged together
   - Validate and distribute through App Store Connect

### Distribution Checklist

- [ ] Both targets have correct bundle identifiers
- [ ] App Group is configured and matches in both targets
- [ ] Signing certificates are valid
- [ ] Info.plist entries are correct
- [ ] Privacy descriptions are added (if required)
- [ ] Tested on physical device

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute to BashkirKeyboard:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows the existing style and includes appropriate tests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: This keyboard requires Full Access to sync theme preferences between the main app and the keyboard extension. No data is collected or transmitted outside the device.

