# PhotoPin

<p align="center">
  <img src="assets/app_icons/app_icon.png" alt="PhotoPin Logo" width="150"/>
</p>

<h3 align="center">Your Memories Mapped</h3>
<p align="center"><i>Pin your photos to real locations and bring your memories to life!</i></p>

---

## Περιγραφή

Το **PhotoPin** είναι μια εφαρμογή φωτογραφίας που συνδυάζει τις αναμνήσεις σας με τον χάρτη του κόσμου. Κάθε φωτογραφία που τραβάτε καρφιτσώνεται αυτόματα στην ακριβή τοποθεσία που βρισκόσασταν, δημιουργώντας έναν διαδραστικό χάρτη των στιγμών σας.

**Χαρακτηριστικά:**
- 🗺️ **Χάρτης με spotlight effect**: Ο χάρτης εμφανίζεται σε γκρίζες αποχρώσεις, αλλά κάθε φωτογραφία που προσθέτετε "φωτίζει" την περιοχή γύρω της με έγχρωμο spotlight
- 📸 **Φωτογραφία με GPS**: Τραβήξτε φωτογραφίες μέσα από την εφαρμογή και καρφιτσώστε τις αυτόματα στον χάρτη
- 🎤 **Speech-to-Text**: Προσθέστε περιγραφές στις φωτογραφίες σας χρησιμοποιώντας φωνητικές εντολές
- 🎮 **Gamification**: Γεμίστε τον χάρτη με τις φωτογραφίες σας και ξεκλειδώστε περιοχές γύρω σας
- 🌗 **Dark/Light Theme**: Υποστήριξη σκοτεινού και φωτεινού θέματος

---

## Screenshots

<p align="center">
  <img src="screenshots/map_screen_1.png" alt="Map Screen 1" width="220"/>
  <img src="screenshots/map_screen_2.png" alt="Map Screen 2" width="220"/>
  <img src="screenshots/memories_list_1.png" alt="Memories List 1" width="220"/>
</p>

<p align="center">
  <img src="screenshots/memories_list_2.png" alt="Memories List 2" width="220"/>
  <img src="screenshots/photo_detail.png" alt="Photo Detail" width="220"/>
</p>

---

## Τεχνολογίες

**Ανάπτυξη Εφαρμογής:**
- [Flutter](https://flutter.dev/) v3.9.2+
- [Dart](https://dart.dev/)

**Χάρτης:**
- [flutter_map](https://pub.dev/packages/flutter_map) - Flexible mapping library
  - Υποστηρίζει πολλαπλούς tile providers:
    - [OpenStreetMap](https://www.openstreetmap.org/) (default - δωρεάν)
    - [Mapbox](https://www.mapbox.com/), Google Maps, κ.ά. (για scalability σε production)
  - Εύκολη εναλλαγή providers στο `lib/features/map/presentation/screens/map_screen.dart` (αλλαγή του `urlTemplate` στο `TileLayer`)

**Αποθήκευση Δεδομένων:**
- [SharedPreferences](https://pub.dev/packages/shared_preferences) για τοπική αποθήκευση αναμνήσεων
- Τοπικό σύστημα αρχείων για φωτογραφίες

**Άλλες Βιβλιοθήκες:**
- `geolocator` - Λήψη GPS συντεταγμένων
- `geocoding` - Μετατροπή συντεταγμένων σε διευθύνσεις
- `image_picker` - Λήψη φωτογραφιών από κάμερα/gallery
- `speech_to_text` - Φωνητική αναγνώριση για περιγραφές
- `permission_handler` - Διαχείριση δικαιωμάτων
- `google_fonts` - Custom γραμματοσειρές

---

## Απαιτήσεις Συστήματος

### Android
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: Latest stable (auto-configured by Flutter)
- **Compile SDK**: Latest stable (auto-configured by Flutter)
- **Permissions**: Camera, Microphone, GPS, Storage

### iOS
- **Minimum iOS Version**: 12.0+
- **Xcode**: 14.0+

> **Σημείωση**: Η εφαρμογή δεν απαιτεί Google Play Services ή Google Maps API. Χρησιμοποιεί OpenStreetMap που λειτουργεί σε όλες τις συσκευές Android (συμπεριλαμβανομένων εκείνων χωρίς GMS).

---

## Εγκατάσταση και Εκτέλεση

### Προαπαιτούμενα για να χτίσετε μόνοι σας το apk

1. **Εγκατάσταση Flutter SDK**
   - Κατεβάστε το [Flutter SDK](https://flutter.dev/docs/get-started/install) για το λειτουργικό σας σύστημα
   - **Απαιτείται έκδοση**: Flutter 3.9.2 ή νεότερη
   - Προσθέστε το Flutter στο PATH σας
   - Εκτελέστε `flutter doctor` για να επαληθεύσετε την εγκατάσταση

2. **Android Development**
   - Εγκαταστήστε το [Android Studio](https://developer.android.com/studio)
   - Εγκαταστήστε Android SDK μέσω του Android Studio SDK Manager
   - Δημιουργήστε ένα Android emulator ή συνδέστε μια φυσική συσκευή

3. **iOS Development** (μόνο για macOS)
   - Εγκαταστήστε το [Xcode](https://apps.apple.com/us/app/xcode/id497799835)
   - Εκτελέστε `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
   - Εκτελέστε `sudo xcodebuild -runFirstLaunch`

### Βήματα Εγκατάστασης

#### Μπορείτε να κατεβάσετε το **latests realese** από τα **releases** ή να χτίσετε μόνοι σας το apk ακολουθώντας τα ακόλουθα βήματα

1. **Clone το repository** (ή κατεβάστε το ZIP)
   ```bash
   git clone <repository-url>
   cd PhotoPin
   ```

2. **Εγκατάσταση dependencies**
   ```bash
   flutter pub get
   ```

3. **Επαλήθευση συνδεδεμένων συσκευών**
   ```bash
   flutter devices
   ```

4. **Εκτέλεση της εφαρμογής**
   ```bash
   # Για Android
   flutter run

   # Ή για συγκεκριμένη συσκευή
   flutter run -d <device-id>

   # Για release mode (καλύτερη απόδοση)
   flutter run --release
   ```

### Build APK για Android

Για να δημιουργήσετε ένα APK αρχείο για εγκατάσταση σε Android συσκευές:

```bash
# Debug APK (για δοκιμές)
flutter build apk --debug

# Release APK (βελτιστοποιημένο για παραγωγή)
flutter build apk --release

# Το APK θα βρίσκεται στο:
# build/app/outputs/flutter-apk/app-release.apk
```

Για πιο μικρό μέγεθος APK (split per ABI):
```bash
flutter build apk --split-per-abi
```

---

## Οδηγίες Χρήσης

### Πρώτη Εκκίνηση

1. **Χορήγηση Δικαιωμάτων**
   - Η εφαρμογή ζητά δικαιώματα κατά την πρόσβαση σε κάθε λειτουργία:
     - **GPS**: Για τη φόρτωση του χάρτη και τον εντοπισμό θέσης
     - **Κάμερα**: Για τη λήψη φωτογραφιών
     - **Μικρόφωνο**: Για τη χρήση του speech-to-text
     - **Αποθήκευση**: Για την αποθήκευση φωτογραφιών
   - **Σημαντικό**: Χορηγήστε τα δικαιώματα για πλήρη λειτουργικότητα

2. **Περιήγηση στον Χάρτη**
   - Ο χάρτης θα εμφανιστεί σε γκρίζες αποχρώσεις
   - Το κουμπί στην κάτω δεξιά γωνία σας μεταφέρει στην τρέχουσα θέση σας

### Προσθήκη Φωτογραφίας

1. Πατήστε το μεσαίο κουμπί **+** στην κάτω μπάρα πλοήγησης
2. Τραβήξτε φωτογραφία με την κάμερα
3. Μετά τη λήψη:
   - Η εφαρμογή λαμβάνει αυτόματα τις GPS συντεταγμένες
   - Μετατρέπει τις συντεταγμένες σε διεύθυνση (π.χ. "Αθήνα, Ελλάδα")
4. **Προσθήκη Περιγραφής**:
   - Πληκτρολογήστε μια περιγραφή, **ή**
   - Πατήστε το εικονίδιο μικροφώνου για φωνητική περιγραφή
   - Μιλήστε και η εφαρμογή θα μετατρέψει την ομιλία σας σε κείμενο
5. Πατήστε **Αποθήκευση**

### Προβολή Αναμνήσεων

1. **Από τον Χάρτη**:
   - Οι φωτογραφίες σας εμφανίζονται ως markers στον χάρτη
   - Κάθε φωτογραφία δημιουργεί ένα έγχρωμο "spotlight" γύρω της
   - Πατήστε σε ένα marker για να δείτε λεπτομέρειες

2. **Από τη Λίστα Αναμνήσεων**:
   - Πατήστε το εικονίδιο λίστας στην κάτω μπάρα
   - Δείτε όλες τις αναμνήσεις σε μορφή λίστας
   - Πατήστε σε μια ανάμνηση για πλήρεις λεπτομέρειες

### Ρυθμίσεις

Πατήστε το εικονίδιο ρυθμίσεων στην κάτω μπάρα για εναλλαγή Dark/Light theme.

---

## Αρχιτεκτονική Εφαρμογής

Η εφαρμογή ακολουθεί την αρχιτεκτονική **Feature-First** με διαχωρισμό σε layers:

```
lib/
├── main.dart                 # Entry point
├── core/                     # Shared resources
│   ├── app_theme.dart
│   └── app_colors.dart
├── common_widgets/           # Reusable widgets
│   └── app_topbar.dart
└── features/                 # Feature modules
    ├── map/                  # Χάρτης με spotlights
    ├── memories/             # Διαχείριση αναμνήσεων
    ├── add_memory/           # Προσθήκη νέας ανάμνησης
    ├── settings/             # Ρυθμίσεις
    └── root/                 # Navigation root

Κάθε feature:
├── data/                     # Data sources
├── domain/                   # Business logic & models
└── presentation/             # UI (screens, widgets, controllers)
```

---

## Δεδομένα και Αποθήκευση

- **Φωτογραφίες**: Αποθηκεύονται στο τοπικό filesystem της εφαρμογής
- **Metadata**: Αποθηκεύονται σε SharedPreferences (JSON format)
- **Δομή Memory**:
  ```json
  {
    "id": "unique-id",
    "title": "Memory Title",
    "date": "2026-01-17T10:30:00.000",
    "location": "Athens, Greece",
    "imagePath": "/path/to/image.jpg",
    "caption": "User description",
    "lat": 37.9838,
    "lng": 23.7275
  }
  ```

---

<p align="center">Made with Flutter</p>


