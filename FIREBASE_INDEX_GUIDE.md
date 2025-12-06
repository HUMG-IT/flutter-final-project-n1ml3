# Hướng dẫn tạo Firestore Index

## Vấn đề

Khi query Firestore với `where` và `orderBy` trên các field khác nhau, Firestore yêu cầu **composite index**. 

## Giải pháp đã áp dụng

Code đã được sửa để **không cần index** bằng cách:
1. Query chỉ với `where('user_id')` 
2. Sort trong code sau khi lấy dữ liệu

Điều này hoạt động tốt với dữ liệu nhỏ đến trung bình.

## Nếu muốn tạo Index để tối ưu hiệu suất

Nếu bạn có nhiều todos (hàng trăm hoặc hàng nghìn), nên tạo index để tối ưu:

### Cách 1: Click vào link trong lỗi

Khi gặp lỗi index, Firebase sẽ cung cấp link để tạo index tự động. Chỉ cần:
1. Click vào link trong thông báo lỗi
2. Firebase Console sẽ mở với form tạo index
3. Click "Create Index"
4. Đợi vài phút để index được tạo

### Cách 2: Tạo thủ công trong Firebase Console

1. Vào Firebase Console > Firestore Database
2. Vào tab **"Indexes"**
3. Click **"Create Index"**
4. Cấu hình:
   - **Collection ID**: `todos`
   - **Fields to index**:
     - Field: `user_id`, Order: Ascending
     - Field: `created_at`, Order: Descending
   - **Query scope**: Collection
5. Click **"Create"**

### Index cần tạo

**Index 1: Cho query cơ bản**
- Collection: `todos`
- Fields:
  - `user_id` (Ascending)
  - `created_at` (Descending)

**Index 2: Cho filter theo is_completed (nếu cần)**
- Collection: `todos`
- Fields:
  - `user_id` (Ascending)
  - `is_completed` (Ascending)
  - `created_at` (Descending)

**Index 3: Cho filter theo priority (nếu cần)**
- Collection: `todos`
- Fields:
  - `user_id` (Ascending)
  - `priority` (Ascending)
  - `created_at` (Descending)

## Lưu ý

- Index mất vài phút để tạo xong
- Index chỉ cần tạo một lần
- Code hiện tại đã hoạt động không cần index, nhưng index sẽ giúp query nhanh hơn với dữ liệu lớn

