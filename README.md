# [Download APK (Google Drive Link)](https://drive.google.com/drive/folders/1U_VSI1ELwWuux0guhhbSOrxdY6b3f2BE?usp=drive_link)

# [Download Report ](https://github.com/hbnasir23/dbms/blob/main/SYSTEM%20ARCHITECTURE%20AND%20DESIGN.pdf)

# Health App (DBMS Project)

A comprehensive Flutter-based healthcare management application designed to connect Users, Doctors, and Administrators. This project facilitates appointment scheduling, pharmacy management, and secure user authentication.

## 🌟 Features

* **Role-Based Access Control**:
    * **User Dashboard**: Browse pharmacy, manage cart, view purchase history, and book appointments.
    * **Doctor Dashboard**: Manage schedules, view appointments, and update profile.
    * **Admin Dashboard**: Manage users, doctors, and pharmacy inventory.
* **Authentication**: Secure Login and Signup screens for different roles using Supabase.
* **Pharmacy & Cart**:
    * Add items to cart.
    * Address and payment processing.
    * Purchase history tracking.
* **Maps Integration**: Location services using `flutter_map` and `latlong2`.
* **Real-time Database**: Powered by Supabase for instant data updates.

## 🛠️ Tech Stack

* **Framework**: Flutter (Dart)
* **Backend**: Supabase (PostgreSQL, Auth)
* **State Management**: Provider
* **Maps**: flutter_map, latlong2
* **Storage**: flutter_secure_storage
* **Utilities**: intl, image_picker, url_launcher, crypt

## 📦 Dependencies

This project relies on the following major packages:

* `supabase_flutter`: ^2.0.0
* `provider`: ^6.0.5
* `flutter_map`: ^8.1.1
* `flutter_secure_storage`: ^9.2.4
* `modal_bottom_sheet`: ^3.0.0
* `image_picker`: ^1.0.7
* `intl`: ^0.20.2

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

## 👥 Authors

* **HARIS**

---
*Note: Make sure to update the Supabase URL and Anon Key in `lib/main.dart` if you are deploying to a new environment.*
