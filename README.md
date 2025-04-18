<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
Here’s a cleaner, more professional, and visitor-friendly version of your README for the **FoodPOS** project. It improves structure, grammar, clarity, and adds clickable sections for better navigation.

---

# 🍔 FoodPOS

**A Flutter-based Point of Sale (POS) app for restaurants**, designed to manage menu items and process orders efficiently. Built with Firebase Firestore and local assets, optimized to stay within Firebase’s free Spark Plan.

📦 **Repository**: [GitHub - mobile_application](https://github.com/fuadhossainnishad/mobile_application.git)

**UI/UX design link**: (https://www.figma.com/design/pnySRrCbu7aKed3jNnWvlV/FoodPos?node-id=100-115&t=W5ovMaSDlDNBzvNW-1)
---

## 🚀 Features

### 🔐 Role-Based Access
- **Admin**:
  - Add new menu items with name, price, and image from local assets.
- **Buyer**:
  - Browse menu and add items to cart.
- **Guest**:
  - View menu (read-only access).

### 🧾 Menu Management
- Add items with images from `public/images/`.
- Display items in a clean, card-based layout with images and prices.

### 🛒 Order System
- Buyers can place orders directly from the menu interface.

### 🔗 Firebase Integration
- **Firestore**: Stores menu items, orders, and user roles.
- **Authentication**: Email/password login for Admins and Buyers.
- **Assets**: No Firebase Storage used — images are local to stay within the Spark Plan.

### 🌐 Cross-Platform Support
- Fully compatible with **Web**, **iOS**, and **Android** platforms.

---

## ⚙️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Firestore, Firebase Authentication
- **Key Dependencies**:
  ```yaml
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  logger: ^2.4.0
  shared_preferences: ^2.3.2
  intl: ^0.19.0
  ```

---

## 🛠️ Setup Instructions

### 🔗 Prerequisites
- Flutter SDK (v3.0.0+)
- Firebase account
- Code editor (VS Code recommended)
- Git

### 📥 Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/fuadhossainnishad/mobile_application.git
   cd mobile_application
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a project at [Firebase Console](https://console.firebase.google.com).
   - Enable **Authentication** (Email/Password) and **Firestore**.
   - Register Android/iOS/Web app in Firebase.
   - Download `firebase_options.dart` from Firebase and place it in `lib/`.

4. **Set Firestore Rules**
   ```js
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /menu_items/{document=**} {
         allow read: if true;
         allow write: if request.auth != null;
       }
       match /users/{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
   Then run:
   ```bash
   firebase deploy --only firestore:rules
   ```

5. **Set Up Image Assets**
   Ensure `public/images/` includes:
   - `burger.jpg`
   - `pizza.png`
   - `fries.jpg`
   - `placeholder.jpg`

   Confirm in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - public/images/burger.jpg
       - public/images/pizza.png
       - public/images/fries.jpg
       - public/images/placeholder.jpg
   ```

6. **Run the App**
   - **Web**:
     ```bash
     flutter run -d chrome
     ```
   - **Mobile**:
     ```bash
     flutter run -d <device>
     ```

---

## 🧱 Project Structure

```
mobile_application/
├── lib/
│   ├── auth/
│   │   └── backend_service.dart      # Firebase operations
│   ├── add_item_screen.dart         # Admin interface for adding items
│   ├── menu_screen.dart             # Display menu items
│   ├── order_screen.dart            # View and manage orders
│   ├── bottom_nav_bar.dart          # Bottom navigation bar
│   ├── main.dart                    # App entry point
│   └── firebase_options.dart        # Firebase configuration
├── public/
│   └── images/                      # Static image assets
├── pubspec.yaml                     # Dependencies and assets
└── README.md                        # Project documentation
```

---

## 👥 User Guide

### 👨‍💼 Admin
- Login using Firebase-authenticated credentials.
- Navigate to **Menu** → Tap **Floating Action Button (FAB)**.
- Add item: name, price, and select an image from `public/images/`.
- Items will be listed in the menu with their images.

### 🧑‍💼 Buyer
- Login with Buyer credentials.
- Browse menu and tap “Add to Cart” to initiate an order.

### 👀 Guest
- No login required.
- Can view menu items in read-only mode.

---

## ✅ Testing

### Admin
- Add item (e.g., Burger, 200 BDT, burger.jpg).
- Verify menu shows item with image.
- Confirm Firestore `menu_items`:
  ```json
  {
    "name": "Burger",
    "price": 200,
    "imageUrl": "public/images/burger.jpg"
  }
  ```

### Buyer
- Add to cart and navigate to Order Screen.

### Logs
- Run `flutter logs` to view debug output:
  ```
  Added menu item: Burger
  ```

### Devices
- Test across:
  - ✅ Chrome
  - ✅ Android Emulator/Device
  - ✅ iOS Simulator/Device

---

## 🧪 Troubleshooting

| Issue | Solution |
|-------|----------|
| 🔴 **Images not showing** | Check `pubspec.yaml` asset paths. Update `_availableImages` in `AddItemScreen.dart`. |
| 🔴 **Firestore permissions denied** | Verify Firestore rules and `firebase_options.dart`. |
| 🔴 **Auth errors** | Ensure Firestore `users/<uid>` has correct `role` field. |
| 🔴 **App not loading** | Check logs for `_logger.e(...)` error messages. |

---

## 🤝 Contributing

1. Fork the repository.
2. Create your feature branch:
   ```bash
   git checkout -b feature/your-feature
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your feature"
   ```
4. Push to the branch:
   ```bash
   git push origin feature/your-feature
   ```
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 📬 Contact

For issues, please open a [GitHub Issue](https://github.com/fuadhossainnishad/mobile_application/issues).

---

Let me know if you'd like a custom badge or banner for the top of the README, or if you want to turn this into a GitHub Pages site!

=======
# food

A new Flutter project.

## Getting Started from here

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> mahazabin_5755
