# Câu hỏi thường gặp về Firebase Setup

## Database có được tạo tự động không?

### Câu trả lời: CÓ, nhưng có điều kiện

**Firestore Database sẽ tự động tạo collections và documents khi:**
1. ✅ Firestore Database đã được tạo trong Firebase Console
2. ✅ Security Rules đã được cấu hình đúng
3. ✅ Authentication đã được bật
4. ✅ Ứng dụng ghi dữ liệu lần đầu tiên

### Quy trình tự động:

1. **Khi người dùng đăng ký lần đầu:**
   - Collection `users` sẽ được tạo tự động
   - Document với ID là UID của user sẽ được tạo trong collection `users`

2. **Khi người dùng tạo todo đầu tiên:**
   - Collection `todos` sẽ được tạo tự động
   - Document với ID là UUID của todo sẽ được tạo trong collection `todos`

### Bạn KHÔNG cần:
- ❌ Tạo collections trước trong Firebase Console
- ❌ Tạo documents trước
- ❌ Cấu hình schema trước

### Bạn CẦN:
- ✅ Tạo Firestore Database trong Firebase Console (chỉ cần tạo database, không cần tạo collections)
- ✅ Cấu hình Security Rules
- ✅ Bật Authentication

## Sự khác biệt giữa Realtime Database và Firestore Database

### Realtime Database
- Database dạng JSON tree
- URL có dạng: `https://project-id-default-rtdb.firebaseio.com`
- Không phù hợp với dự án này

### Firestore Database (Dự án này sử dụng)
- Database dạng NoSQL document
- URL có dạng: `https://console.firebase.google.com/project/project-id/firestore`
- Phù hợp với dự án này
- Collections và documents được tạo tự động khi ghi dữ liệu

## Kiểm tra xem đã tạo đúng database chưa

### Trong Firebase Console:
1. Vào **Firestore Database** (KHÔNG phải Realtime Database)
2. Nếu thấy tab **"Data"**, **"Rules"**, **"Indexes"** → Đúng rồi
3. Nếu chỉ thấy URL và không có tabs → Đó là Realtime Database (SAI)

### Trong code:
- Dự án sử dụng `cloud_firestore` package
- Code sử dụng `FirebaseFirestore.instance`
- Nếu thấy `FirebaseDatabase.instance` → SAI (đó là Realtime Database)

## Troubleshooting

### Lỗi: "Missing or insufficient permissions"
- **Nguyên nhân**: Security Rules chưa được cấu hình đúng
- **Giải pháp**: Cập nhật Security Rules trong tab **"Rules"** của Firestore Database

### Lỗi: "Collection not found"
- **Nguyên nhân**: Chưa có dữ liệu nào được ghi
- **Giải pháp**: Chạy ứng dụng và tạo dữ liệu đầu tiên (đăng ký user hoặc tạo todo)

### Collections không xuất hiện trong Firebase Console
- **Nguyên nhân**: Chưa có dữ liệu nào được ghi vào collection đó
- **Giải pháp**: 
  1. Đảm bảo ứng dụng đã ghi dữ liệu thành công
  2. Refresh lại Firebase Console
  3. Kiểm tra Security Rules có cho phép ghi không

## Checklist trước khi chạy ứng dụng

- [ ] Firestore Database đã được tạo (KHÔNG phải Realtime Database)
- [ ] Security Rules đã được cấu hình
- [ ] Authentication > Email/Password đã được bật
- [ ] File `google-services.json` đã được thêm vào `android/app/`
- [ ] Đã chạy `flutter pub get`
- [ ] Đã chạy `flutter run`

Sau khi checklist đầy đủ, collections sẽ được tạo tự động khi bạn:
1. Đăng ký tài khoản đầu tiên → Collection `users` xuất hiện
2. Tạo todo đầu tiên → Collection `todos` xuất hiện

