# 🏍️ MotoLog — Nhật ký xe cá nhân

[![iOS Build](https://github.com/TranhaidangIT/MotoLog_Mobile/actions/workflows/ios_build.yml/badge.svg)](https://github.com/TranhaidangIT/MotoLog_Mobile/actions/workflows/ios_build.yml)

Ứng dụng Flutter quản lý nhật ký xe cá nhân với Firebase Authentication và Cloud Firestore đồng bộ dữ liệu.

## ✨ Tính năng chính

- 🔐 Đăng nhập bằng Email/Password hoặc Google Sign-In (Firebase Auth)
- 🏍️ Quản lý nhiều xe, thông tin chi tiết từng xe
- ⛽ Nhật ký đổ xăng, tính tiêu hao L/100km tự động
- 🔧 Lịch bảo dưỡng, nhắc nhở đến hạn
- 📊 Thống kê chi phí bằng biểu đồ (fl_chart)
- ☁️ Đồng bộ dữ liệu lên Cloud Firestore
- 🌙 Hỗ trợ Light/Dark Mode

## 🛠 Công nghệ sử dụng

- **Flutter** + **Dart**
- **Firebase** (Auth, Firestore)
- **Riverpod** (State Management)
- **GoRouter** (Navigation)
- **SQLite** (Local Database — sqflite)
- **GitHub Actions** (CI/CD — Auto build iOS IPA)

## 📱 Cài đặt iOS (không cần tài khoản Apple Developer)

Tải file `.ipa` mới nhất từ trang [Releases](https://github.com/TranhaidangIT/MotoLog_Mobile/releases) và cài đặt bằng phần mềm [Sideloadly](https://sideloadly.io/) (miễn phí).

## 🚀 Chạy dự án

```bash
# Cài đặt dependencies
flutter pub get

# Chạy trên thiết bị/emulator
flutter run
```

## 📚 Cấu trúc thư mục

```
lib/
├── core/          # Colors, Theme, Router, Utils
├── data/          # Models, DAOs, Services (Firestore)
├── providers/     # Riverpod Providers (Auth, Vehicle, Fuel...)
└── screens/       # Tất cả các màn hình UI
```
