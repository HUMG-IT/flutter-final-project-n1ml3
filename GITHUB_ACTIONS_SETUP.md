# GitHub Actions CI/CD Setup Guide

Hướng dẫn thiết lập và sử dụng GitHub Actions CI/CD cho dự án Flutter này.

## 📋 Mục Lục

1. [Giới Thiệu](#giới-thiệu)
2. [Cấu Trúc Workflows](#cấu-trúc-workflows)
3. [Thiết Lập Ban Đầu](#thiết-lập-ban-đầu)
4. [Cấu Hình Keystore Android](#cấu-hình-keystore-android)
5. [Cấu Hình Signing iOS](#cấu-hình-signing-ios)
6. [Secrets & Variables](#secrets--variables)
7. [Monitoring & Troubleshooting](#monitoring--troubleshooting)

## 🎯 Giới Thiệu

Dự án này được cấu hình với GitHub Actions để tự động:
- ✅ Chạy unit tests
- ✅ Kiểm tra code formatting
- ✅ Phân tích code với Flutter Analyze
- ✅ Build APK & AAB cho Android
- ✅ Build IPA cho iOS
- ✅ Tạo releases tự động
- ✅ Upload coverage reports
- ✅ Chạy integration tests

## 📁 Cấu Trúc Workflows

### 1. **ci.yml** - CI/CD Chính
```
Trigger: Push vào main/develop, Pull Requests
Tasks:
  - Checkout code
  - Setup Flutter (3.24.0)
  - Cài dependencies
  - Kiểm tra formatting (dart format)
  - Phân tích code (flutter analyze)
  - Chạy unit tests với coverage
  - Upload coverage to Codecov
  - Publish coverage report
```

### 2. **build-android.yml** - Build Android
```
Trigger: Push vào main/develop, Tags v*, Pull Request vào main
Tasks:
  - Setup Java 17 + Gradle cache
  - Build APK Debug (split per ABI)
  - Build AAB Release (chỉ với tags)
  - Upload artifacts (30 ngày)
```

### 3. **build-ios.yml** - Build iOS
```
Trigger: Push vào main/develop, Tags v*, Pull Request vào main
Runner: macOS 14
Tasks:
  - Setup Flutter
  - Build iOS Debug
  - Build iOS Release (với tags)
  - Upload build artifacts
```

### 4. **release.yml** - GitHub Release
```
Trigger: Khi tag v* được push
Tasks:
  - Build APK Release
  - Generate changelog
  - Tạo GitHub Release
  - Upload artifacts
  - Auto-detect beta/alpha releases
```

### 5. **integration-tests.yml** - Integration Tests
```
Trigger: Push vào main/develop, Pull Request vào main
Tasks:
  - Chạy integration tests
  - Upload test results
  - Report status
```

## 🚀 Thiết Lập Ban Đầu

### 1. Clone hoặc đã có repository
```bash
git clone https://github.com/HUMG-IT/flutter-final-project-n1ml3.git
cd flutter-final-project-n1ml3
```

### 2. Kiểm tra workflows
Tất cả file workflows nằm tại `.github/workflows/`:
```
.github/
└── workflows/
    ├── ci.yml                 # CI tests & analysis
    ├── build-android.yml      # Android build
    ├── build-ios.yml          # iOS build
    ├── release.yml            # Release tự động
    └── integration-tests.yml  # Integration tests
```

### 3. Kích hoạt Actions
Đi tới: **Settings → Actions → General**
- Đảm bảo "Allow all actions and reusable workflows" được chọn

### 4. Thử chạy workflow lần đầu
Đẩy code lên GitHub:
```bash
git add .
git commit -m "Setup GitHub Actions CI/CD"
git push origin main
```

Kiểm tra: **Actions tab** trên GitHub

## 🔐 Cấu Hình Keystore Android

Để build APK Release tự động, bạn cần setup keystore:

### 1. Tạo Keystore (nếu chưa có)
```bash
keytool -genkey -v -keystore ~/my-release-key.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

### 2. Encode Keystore thành Base64
```bash
# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\my-release-key.keystore")) | Set-Clipboard

# macOS/Linux
base64 -i ~/my-release-key.keystore
```

### 3. Thêm GitHub Secrets
Đi tới: **Settings → Secrets and variables → Actions → New repository secret**

Thêm các secrets sau:
```
ANDROID_KEYSTORE_BASE64      = <Base64 encoded keystore>
ANDROID_KEYSTORE_PASSWORD    = <Your keystore password>
ANDROID_KEY_ALIAS            = my-key-alias
ANDROID_KEY_PASSWORD         = <Your key password>
```

### 4. Cập nhật build.gradle
Thêm vào `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        keyAlias System.getenv('ANDROID_KEY_ALIAS') ?: 'release'
        keyPassword System.getenv('ANDROID_KEY_PASSWORD')?.toCharArray()
        storeFile file(System.getenv('KEYSTORE_PATH') ?: 'keystore.jks')
        storePassword System.getenv('ANDROID_KEYSTORE_PASSWORD')
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

### 5. Cập nhật workflow build-android.yml
```yaml
- name: Setup Keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > $RUNNER_TEMP/keystore.jks
  
- name: Build APK (Release)
  run: flutter build apk --release
  env:
    KEYSTORE_PATH: ${{ runner.temp }}/keystore.jks
    ANDROID_KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
    ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
    ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
```

## 🍎 Cấu Hình Signing iOS

Để build iOS Release, bạn cần Apple Developer credentials:

### 1. Tạo Provisioning Profile & Certificate
- Đi tới [Apple Developer](https://developer.apple.com)
- Tạo Certificate, Identifier, Provisioning Profile
- Download các file này

### 2. Encode thành Base64
```bash
base64 -i ~/path/to/provisioning-profile.mobileprovision
base64 -i ~/path/to/certificate.p12
```

### 3. Thêm GitHub Secrets
```
APPLE_CERT_BASE64              = <Certificate Base64>
APPLE_CERT_PASSWORD            = <Certificate Password>
APPLE_PROVISIONING_PROFILE      = <Profile Base64>
APPLE_TEAM_ID                  = <Team ID>
```

### 4. Cập nhật build-ios.yml (nếu cần production build)

## 📦 Secrets & Variables

### Repository Secrets (Repository → Settings → Secrets)

#### Bắt buộc:
```
GITHUB_TOKEN        = Tự động (không cần setup)
```

#### Tuỳ chọn (cho production):
```
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
APPLE_CERT_BASE64
APPLE_CERT_PASSWORD
APPLE_PROVISIONING_PROFILE
APPLE_TEAM_ID
```

### Environment Variables
Có thể thêm vào file `.github/workflows/*.yml`:
```yaml
env:
  FLUTTER_VERSION: '3.24.0'
  JAVA_VERSION: '17'
```

## 📊 Monitoring & Troubleshooting

### Xem Build Logs
1. Đi tới **Actions tab**
2. Chọn workflow run
3. Chọn job
4. Xem detailed logs

### Kiểm Tra Status Badge
Thêm vào `README.md`:
```markdown
![CI Tests](https://github.com/HUMG-IT/flutter-final-project-n1ml3/actions/workflows/ci.yml/badge.svg)
![Android Build](https://github.com/HUMG-IT/flutter-final-project-n1ml3/actions/workflows/build-android.yml/badge.svg)
![iOS Build](https://github.com/HUMG-IT/flutter-final-project-n1ml3/actions/workflows/build-ios.yml/badge.svg)
```

### Các Lỗi Phổ Biến

#### 1. Lỗi: "flutter: command not found"
**Nguyên nhân**: Flutter chưa được cài đặt
**Giải pháp**: Workflow đã có `subosito/flutter-action@v2` để setup

#### 2. Lỗi: "Java version mismatch"
**Nguyên nhân**: Java version không khớp
**Giải pháp**: Cập nhật `java-version: '17'` trong build-android.yml

#### 3. Lỗi: Tests không chạy
**Nguyên nhân**: Dependencies không được cài
**Giải pháp**: Chạy `flutter pub get` trước

#### 4. Lỗi: Keystore signature failed
**Nguyên nhân**: Keystore credentials sai
**Giải pháp**: 
- Kiểm tra GitHub Secrets
- Xác nhận password keystore

### Debug Commands
```bash
# Chạy tests locally
flutter test --coverage

# Chạy analysis
flutter analyze

# Check formatting
dart format --set-exit-if-changed .

# Build APK debug
flutter build apk --debug

# Build release
flutter build apk --release
```

## 🎬 Các Quy Trình Thường Gặp

### Tạo Release Mới
```bash
# Tag version
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag (tự động trigger release.yml)
git push origin v1.0.0
```

### Chạy Workflow Thủ Công
Đi tới **Actions → Select Workflow → Run workflow**

### Bỏ Qua Workflow
Thêm vào commit message:
```
git commit -m "Update docs [skip ci]"
```

## 📚 Tài Liệu Tham Khảo

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://flutter.dev/docs/testing/ci)
- [Subosito Flutter Action](https://github.com/subosito/flutter-action)
- [Setup Java Action](https://github.com/actions/setup-java)
- [Codecov Integration](https://docs.codecov.com/docs/github-actions)

## ✅ Checklist Hoàn Tất

- [ ] Workflows được thiết lập
- [ ] GitHub Actions được kích hoạt
- [ ] Tests chạy thành công
- [ ] Android Keystore được cấu hình (nếu cần)
- [ ] iOS Signing được cấu hình (nếu cần)
- [ ] Coverage reports được upload
- [ ] Release workflow được kiểm tra
- [ ] Status badges được thêm vào README

## 💡 Tips & Tricks

1. **Tăng tốc độ builds**:
   - Sử dụng `cache: true` trong Flutter setup
   - Sử dụng `cache: gradle` cho Java

2. **Reduce artifact storage**:
   - Giảm `retention-days` nếu cần
   - Xoá artifacts cũ manually

3. **Monitor costs**:
   - GitHub Actions miễn phí cho public repos
   - Private repos có giới hạn 3000 minutes/month

4. **Security best practices**:
   - Không commit secrets vào git
   - Dùng GitHub Secrets cho credentials
   - Review logs thường xuyên

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra logs chi tiết trong Actions tab
2. Xem section Troubleshooting ở trên
3. Kiểm tra GitHub Actions status page
4. Tham khảo tài liệu Flutter CI/CD

---

**Last Updated**: December 2025
**Flutter Version**: 3.24.0
**Status**: ✅ Production Ready
