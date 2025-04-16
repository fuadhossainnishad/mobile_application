FoodPOS
A Flutter-based Point of Sale (POS) application for restaurants, allowing admins to manage menu items and buyers to place orders. Built with Firebase Firestore for data storage and local assets for images to stay within Firebase’s free Spark Plan.
Repository: https://github.com/fuadhossainnishad/mobile_application.git
Features

Role-Based Access:
Admins: Add menu items (name, price, image from public/images/).
Buyers: View menu and add items to cart.
Guests: View menu (read-only).


Menu Management:
Add items with images selected from local assets.
Display items in a card-based list with images.


Order System:
Buyers can initiate orders from the menu.


Firebase Integration:
Firestore stores menu items, orders, and user roles.
Authentication for admin/buyer login.
No Firebase Storage, using public/images/ assets.


Cross-Platform:
Runs on web, iOS, and Android.



Tech Stack

Frontend: Flutter (Dart)
Backend: Firebase Firestore, Firebase Authentication
Dependencies:
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
logger: ^2.4.0
shared_preferences: ^2.3.2
intl: ^0.19.0



Setup Instructions
Prerequisites

Flutter SDK (3.0.0+)
Firebase account
Code editor (VS Code recommended)
Git

Installation

Clone the Repository:
git clone https://github.com/fuadhossainnishad/mobile_application.git
cd mobile_application


Install Dependencies:
flutter pub get


Configure Firebase:

Create a Firebase project at console.firebase.google.com.
Enable Firestore and Authentication (Email/Password).
Register your app (web, iOS, Android) in Firebase.
Download firebase_options.dart and place it in lib/.
Set Firestore rules:rules_version = '2';
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


Deploy rules:firebase deploy --only firestore:rules




Set Up Images:

Ensure public/images/ contains burger.jpg, pizza.png, fries.jpg, placeholder.jpg.
Verify pubspec.yaml:flutter:
  assets:
    - public/images/burger.jpg
    - public/images/pizza.png
    - public/images/fries.jpg
    - public/images/placeholder.jpg


Run:flutter pub get




Run the App:

Web:flutter run -d chrome


Mobile:flutter run -d <device>





Project Structure
mobile_application/
├── lib/
│   ├── auth/
│   │   └── backend_service.dart    # Firebase operations
│   ├── add_item_screen.dart       # Admin item creation
│   ├── menu_screen.dart           # Menu display
│   ├── order_screen.dart          # Order management
│   ├── bottom_nav_bar.dart        # Bottom navigation
│   ├── main.dart                  # App entry
│   └── firebase_options.dart      # Firebase config
├── public/
│   └── images/                    # Asset images
├── pubspec.yaml                   # Dependencies and assets
└── README.md

Usage

Admin:
Log in (role: 'Admin' in Firestore users/<uid>).
Go to Menu > Floating Action Button > Add Item.
Enter name, price, pick an image from public/images/, and save.
View items in Menu.


Buyer:
Log in (role: 'Buyer').
Browse Menu, click “Add to Cart” to order.


Guest:
View Menu without login.



Testing

Admin:
Add an item (e.g., “Burger”, 200 BDT, burger.jpg).
Check Menu for the item with image.
Verify Firestore menu_items: {name: "Burger", price: 200, imageUrl: "public/images/burger.jpg", ...}.


Buyer:
Add item to cart, ensure OrderScreen loads.


Logs:
Run flutter logs for logger outputs (e.g., Added menu item: ...).


Platforms:
Test on Chrome, iOS, Android.



Troubleshooting

Images Fail:
Check pubspec.yaml for correct asset paths.
Update AddItemScreen.dart’s _availableImages if new images are added.


Firestore Issues:
Verify rules and firebase_options.dart.


Auth Errors:
Ensure users/<uid> has correct role.


Loading Problems:
Check _logger.e in logs for errors.



Contributing

Fork the repo.
Create a branch: git checkout -b feature/your-feature.
Commit: git commit -m "Add feature".
Push: git push origin feature/your-feature.
Open a Pull Request.

License
MIT License
Contact
For issues, open a GitHub issue at https://github.com/fuadhossainnishad/mobile_application.git.
