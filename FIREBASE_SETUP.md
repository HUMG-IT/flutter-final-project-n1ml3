# Hướng dẫn thiết lập Firebase cho dự án Todo App

## Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Nhấn **"Add project"** hoặc **"Tạo dự án"**
3. Nhập tên dự án (ví dụ: `todo-app-flutter`)
4. Chọn có bật Google Analytics hay không (tùy chọn)
5. Nhấn **"Create project"** và đợi Firebase tạo project

## Bước 2: Thêm ứng dụng Android

1. Trong Firebase Console, chọn project vừa tạo
2. Nhấn biểu tượng **Android** (hoặc **Add app** > **Android**)
3. Nhập thông tin:
   - **Android package name**: `com.example.flutter_project` (hoặc package name trong `android/app/build.gradle`)
   - **App nickname** (tùy chọn): Todo App
   - **Debug signing certificate SHA-1** (tùy chọn, có thể bỏ qua)
4. Nhấn **"Register app"**
5. Tải file `google-services.json`
6. Đặt file `google-services.json` vào thư mục `android/app/`

## Bước 3: Thêm ứng dụng iOS (nếu cần)

1. Trong Firebase Console, nhấn **Add app** > **iOS**
2. Nhập thông tin:
   - **iOS bundle ID**: Bundle ID từ Xcode project
   - **App nickname** (tùy chọn): Todo App
3. Nhấn **"Register app"**
4. Tải file `GoogleService-Info.plist`
5. Mở Xcode project và kéo file `GoogleService-Info.plist` vào thư mục `Runner` trong Xcode

## Bước 4: Thiết lập Firebase Authentication

1. Trong Firebase Console, vào **Authentication** (trong menu bên trái)
2. Nhấn **"Get started"** nếu lần đầu sử dụng
3. Vào tab **"Sign-in method"**
4. Bật **Email/Password**:
   - Nhấn vào **Email/Password**
   - Bật **Enable**
   - Nhấn **Save**

## Bước 5: Thiết lập Cloud Firestore Database

**QUAN TRỌNG**: Dự án này sử dụng **Firestore Database**, KHÔNG phải Realtime Database. Đảm bảo bạn tạo Firestore Database, không phải Realtime Database.

1. Trong Firebase Console, vào **Firestore Database** (trong menu bên trái)
   - **Lưu ý**: Không chọn "Realtime Database", hãy chọn "Firestore Database"
2. Nhấn **"Create database"**
3. Chọn chế độ:
   - **Start in test mode** (cho development) - **Lưu ý**: Chỉ dùng cho testing, cần cấu hình Security Rules sau
   - **Start in production mode** (cho production)
4. Chọn **location** (ví dụ: `asia-southeast1` cho Việt Nam)
5. Nhấn **"Enable"**

**Lưu ý về tự động tạo collections:**
- Firestore Database sẽ **TỰ ĐỘNG** tạo collections (`users`, `todos`) và documents khi ứng dụng ghi dữ liệu lần đầu tiên
- Bạn **KHÔNG CẦN** tạo collections trước trong Firebase Console
- Khi người dùng đăng ký tài khoản đầu tiên, collection `users` sẽ được tạo tự động
- Khi người dùng tạo todo đầu tiên, collection `todos` sẽ được tạo tự động

### Cấu hình Security Rules cho Firestore

Sau khi tạo database, vào tab **"Rules"** và cập nhật rules như sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Todos collection - users can only read/write their own todos
    match /todos/{todoId} {
      allow read, write: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.user_id == request.auth.uid;
    }
  }
}
```

**Lưu ý quan trọng**: 
- Rules trên đảm bảo người dùng chỉ có thể đọc/ghi dữ liệu của chính họ
- Trong test mode, mọi người đều có thể đọc/ghi (không an toàn cho production)

## Bước 6: Lấy Firebase Configuration

### Cho Android:
1. Vào **Project Settings** (biểu tượng bánh răng bên cạnh "Project Overview")
2. Scroll xuống phần **"Your apps"**
3. Chọn app Android
4. File `google-services.json` đã được tải ở Bước 2

### Cho iOS:
1. Vào **Project Settings**
2. Chọn app iOS
3. File `GoogleService-Info.plist` đã được tải ở Bước 3

### Web API Key (nếu cần):
1. Vào **Project Settings**
2. Scroll xuống phần **"General"**
3. Tìm **"Web API Key"** - đây là API key cho web (không cần thiết cho mobile app)

## Bước 7: Cấu hình trong Flutter Project

### Android Configuration

1. Đảm bảo file `google-services.json` đã được đặt trong `android/app/`
2. Kiểm tra file `android/build.gradle` có dependency:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
3. Kiểm tra file `android/app/build.gradle` có:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### iOS Configuration

1. Đảm bảo file `GoogleService-Info.plist` đã được thêm vào Xcode project
2. Mở `ios/Runner.xcworkspace` trong Xcode
3. Đảm bảo file `GoogleService-Info.plist` có trong target "Runner"

## Bước 8: Cấu trúc Database trong Firestore

Sau khi thiết lập, database sẽ có cấu trúc như sau:

### Collection: `users`
- Document ID: `{userId}` (UID từ Firebase Auth)
- Fields:
  - `id`: string
  - `email`: string
  - `display_name`: string (optional)
  - `photo_url`: string (optional)
  - `created_at`: timestamp
  - `updated_at`: timestamp

### Collection: `todos`
- Document ID: `{todoId}` (UUID)
- Fields:
  - `id`: string
  - `title`: string
  - `description`: string (optional)
  - `is_completed`: boolean
  - `priority`: string ("low", "medium", "high")
  - `due_date`: timestamp (optional)
  - `created_at`: timestamp
  - `updated_at`: timestamp
  - `user_id`: string (UID của user sở hữu todo)

## Bước 9: Test kết nối

1. Chạy ứng dụng: `flutter run`
2. Đăng ký tài khoản mới
3. Tạo todo đầu tiên
4. Kiểm tra trong Firebase Console:
   - **Authentication** > **Users**: Sẽ thấy user vừa đăng ký
   - **Firestore Database** > **Data**: Sẽ thấy collections `users` và `todos` được tạo **TỰ ĐỘNG** với dữ liệu

**Lưu ý quan trọng:**
- Collections và documents sẽ được tạo **TỰ ĐỘNG** khi ứng dụng ghi dữ liệu lần đầu
- Bạn không cần tạo collections trước trong Firebase Console
- Chỉ cần đảm bảo Firestore Database đã được tạo và Security Rules đã được cấu hình

## Troubleshooting

### Lỗi: "Default FirebaseApp is not initialized"
- Đảm bảo đã gọi `Firebase.initializeApp()` trong `main.dart`
- Kiểm tra file `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS) đã được thêm đúng

### Lỗi: "Permission denied" khi đọc/ghi Firestore
- Kiểm tra Security Rules đã được cấu hình đúng
- Đảm bảo user đã đăng nhập (có `request.auth.uid`)

### Lỗi: "Email already in use"
- Email đã được đăng ký trước đó
- Thử đăng nhập thay vì đăng ký

### Lỗi build Android: "google-services.json not found"
- Đảm bảo file `google-services.json` ở đúng vị trí: `android/app/google-services.json`
- Clean và rebuild: `flutter clean && flutter pub get && flutter run`

## Tài liệu tham khảo

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

## Lưu ý bảo mật

1. **Không commit** file `google-services.json` và `GoogleService-Info.plist` lên public repository
2. Sử dụng **Environment variables** hoặc **Flutter Flavors** cho các môi trường khác nhau
3. Cấu hình **Security Rules** đúng cách trước khi deploy production
4. Sử dụng **Firebase App Check** để bảo vệ backend resources

