
## 📂 Project Root
- `android/` - Android native configuration
- `ios/` - iOS native configuration
- `lib/` - Flutter application source code
- `test/` - Unit and widget tests
- `pubspec.yaml` - Project dependencies and assets

## 📁 lib/ Directory
### 🔹 config/
- `di/` - Dependency Injection setup
- `routes/` - App routing and navigation logic

### 🔹 core/
- `constants/` - Global constants and strings
- `cubit/` - Global state management (Navigation, etc.)
- `network/` - API client and network error handling
- `storage/` - Local storage (SharedPreferences/Secure Storage)
- `theme/` - App colors, typography, and themes
- `usecase/` - Base usecase definitions
- `utils/` - Helper classes and extensions
- `widgets/` - Common UI components (GlassContainer, CustomTextField, etc.)

### 🔹 features/
#### 🔐 auth/
- `data/` - Repositories and data sources for authentication
- `domain/` - Entities and use cases for authentication
- `presentation/` - Cubits, screens (Login, Register, Splash, Onboarding), and widgets

#### 📹 cameras/
- `data/` - Camera-specific data handling and MJPEG streaming
- `domain/` - Camera entities and repository interfaces
- `presentation/` - Camera list and Live Stream screens

#### 🚨 alerts/
- `data/` - Alert logs and notification data
- `domain/` - Alert models
- `presentation/` - Alert history and detail screens

#### 📊 dashboard/
- `presentation/` - Main Home/Overview screen

#### 👤 profile/
- `presentation/` - User profile and settings

#### 📑 reports/
- `presentation/` - Safety report generation and viewing
