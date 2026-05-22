# NAUTICOM — Submarine Control (Flutter)

Phiên bản Flutter/Dart của ứng dụng **Submarine Control App** (React + Vite), giữ nguyên giao diện và luồng chức năng.

## Tính năng

- Đăng nhập bằng mật khẩu (`admin` / `SUBMARINE2024`) hoặc xác thực giọng nói
- Điều khiển bằng giọng nói / nhập lệnh (tiếng Việt & English)
- Bản đồ GPS với vị trí tàu ngầm mô phỏng (OpenStreetMap — không cần API key)
- Lịch sử lệnh, lọc, tìm kiếm
- Chuyển ngôn ngữ VI / EN

## Chạy ứng dụng

```bash
cd submarine_flutter
flutter pub get
flutter run
```

Yêu cầu: Flutter SDK ≥ 3.3, quyền micro (Android/iOS) cho nhận dạng giọng nói.

## Cấu trúc

```
lib/
  main.dart              # Entry, routing đăng nhập / shell
  theme.dart             # Màu & theme (giống React)
  l10n/translations.dart # Bản dịch VI/EN
  models/command.dart
  providers/app_provider.dart
  screens/               # login, voice, map, history, main_shell
  widgets/               # background, lang toggle, sound bars, stat tile
```

## Khác biệt so với bản web

| Web (React) | Flutter |
|-------------|---------|
| Google Maps + API key | OpenStreetMap (`flutter_map`) |
| Web Speech API | `speech_to_text` |
| Tailwind CSS | Material + custom widgets |

Giao diện (màu `#00ffaa`, layout, màn hình) được port trực tiếp từ `src/app/`.
