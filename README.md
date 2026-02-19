# Zimbabwe Document Authenticator - Flutter App

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

A modern Flutter application that scans and authenticates QR codes on official Zimbabwe documents using AES decryption and AI-powered scanning technology.

## ✨ Features

- 🎨 **Beautiful Modern UI** with gradient backgrounds and smooth animations
- 📱 **Splash Screen** with branded animations
- 📜 **Terms & Conditions** acceptance flow
- 📸 **AI-Powered QR Scanning** using Google ML Kit
- 🔐 **AES Decryption** with automatic cipher mode detection
- 💾 **Document History** with local storage
- 🎯 **BLoC State Management** for clean architecture
- 📄 **Document Details** with beautiful presentation

## 🛠️ Technologies Used

- **Flutter 3.0+** - UI Framework
- **BLoC Pattern** - State Management
- **mobile_scanner** - QR Code Scanning
- **encrypt & pointycastle** - AES Cryptography
- **shared_preferences** - Local Storage
- **flutter_animate** - Smooth Animations
- **google_fonts** - Modern Typography

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 or higher)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- An Android device or emulator for testing

## 🚀 Getting Started

### 1. Navigate to Project Directory

```bash
cd c:\Users\bless\Documents\Projects\ZimAuthebticator\flutter_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

#### On Android Emulator/Device:
```bash
flutter run
```

#### On Chrome (for UI testing only - camera won't work):
```bash
flutter run -d chrome
```

### 4. Build APK

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## 📁 Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── blocs/                     # BLoC state management
│   │   ├── scanner/
│   │   │   ├── scanner_bloc.dart
│   │   │   ├── scanner_event.dart
│   │   │   └── scanner_state.dart
│   │   └── document/
│   │       ├── document_bloc.dart
│   │       ├── document_event.dart
│   │       └── document_state.dart
│   ├── models/
│   │   └── document_model.dart    # Document data model
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── terms_screen.dart
│   │   ├── home_screen.dart
│   │   ├── scanner_screen.dart
│   │   └── document_detail_screen.dart
│   └── services/
│       ├── qr_scanner_service.dart
│       └── decryption_service.dart # AES decryption logic
├── android/                        # Android-specific configuration
├── pubspec.yaml                    # Dependencies
└── README.md                       # This file
```

## 🔐 Decryption Details

The app uses **AES encryption** with the following key:
```
UUID: 3649daf5-42cd-4f54-a418-a0736129356e
```

**Supported AES Modes:**
- AES-CBC with IV (prepended to ciphertext)
- AES-CBC with zero IV
- AES-ECB (no IV)
- AES-GCM

The decryption service automatically attempts multiple key derivation methods and cipher modes to ensure compatibility.

## 🎯 Usage

1. **Launch the App** - View the animated splash screen
2. **Accept Terms** - Read and agree to terms & conditions
3. **Scan QR Code** - Tap "Scan AI Code" button on home screen
4. **Point Camera** - Position QR code within the frame
5. **View Results** - Automatically decrypts and displays document details
6. **Access History** - View previously scanned documents from home screen

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/services/decryption_service_test.dart
```

### Check Code Coverage
```bash
flutter test --coverage
```

## 📱 Permissions

The app requires the following permissions:

- **Camera** - For scanning QR codes
- **Internet** - For potential API calls (optional)

These are automatically requested when the scanner is opened.

## 🐛 Troubleshooting

### Camera Permission Denied
- Go to **Settings** → **Apps** → **Zim Authenticator** → **Permissions**
- Enable **Camera** permission

### QR Code Not Scanning
- Ensure good lighting conditions
- Hold the QR code steady within the frame
- Make sure the QR code is not damaged or blurry

### Decryption Fails
- The QR code might be encrypted with a different key
- The QR code format may not match the expected structure
- Check console logs for detailed error messages

## 🔧 Development

### Hot Reload
While the app is running, press `r` in the terminal to hot reload changes.

### Hot Restart
Press `R` (capital R) to hot restart the entire app.

### Debug Mode
```bash
flutter run --debug
```

### Profile Mode (for performance testing)
```bash
flutter run --profile
```

## 📦 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Google ML Kit** - For QR code detection
- **PointyCastle** - For cryptography support
- **Zimbabwe Government** - For the document authentication initiative

## 📞 Support

For issues, questions, or suggestions:
- Create an issue on GitHub
- Email: support@zimauth.com (placeholder)

---

**Made with ❤️ using Flutter**
# app-new
