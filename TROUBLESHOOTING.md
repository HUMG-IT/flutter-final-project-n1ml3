# Troubleshooting - Màn hình đen và lỗi Firebase

## Vấn đề: Màn hình đen khi chạy ứng dụng

### Nguyên nhân có thể:
1. Firebase chưa được khởi tạo đúng cách
2. File `google-services.json` chưa được cấu hình đúng
3. Security Rules chưa được thiết lập
4. Ứng dụng đang chờ Firebase khởi tạo

### Giải pháp:

#### 1. Kiểm tra file google-services.json
- Đảm bảo file `google-services.json` đã được đặt trong `android/app/`
- Kiểm tra package name trong file có khớp với `applicationId` trong `android/app/build.gradle` không

#### 2. Kiểm tra Firebase Console
- Đảm bảo Firestore Database đã được tạo
- Đảm bảo Authentication > Email/Password đã được bật
- Kiểm tra Security Rules đã được cấu hình

#### 3. Xóa cache và rebuild
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

#### 4. Kiểm tra log chi tiết
Chạy với verbose mode:
```bash
flutter run -v
```

#### 5. Kiểm tra kết nối internet
- Firebase cần internet để khởi tạo
- Đảm bảo thiết bị/emulator có kết nối internet

## Lỗi Java Version Warnings

Đã được sửa bằng cách cập nhật:
- Java version: 1.8 → 17
- Kotlin jvmTarget: 1.8 → 17

## Lỗi Firebase Initialization

Nếu vẫn gặp lỗi, kiểm tra:
1. Package name trong `google-services.json` có khớp với `applicationId` không
2. Firebase project đã được tạo đúng chưa
3. File `google-services.json` có đúng định dạng JSON không

