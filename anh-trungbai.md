# MotoLog – V8: Tự động hiện ảnh xe theo Hãng / Dòng / Đời (Firebase + cache local)

> Kiến trúc: Firebase Firestore + Storage giữ "catalog ảnh" (dễ cập nhật không cần build lại app), app cache ảnh về máy sau lần tải đầu (nhanh, hoạt động offline). Có cơ chế fallback nhiều tầng để luôn có ảnh hiển thị dù không khớp chính xác.

---

## 1. Cấu trúc dữ liệu Firestore

### Collection `vehicle_catalog` — mỗi document là 1 dòng xe + khoảng đời

```json
{
  "brand": "Honda",
  "model": "Wave Alpha 110",
  "type": "xe_so",
  "yearFrom": 2019,
  "yearTo": 2023,
  "imageUrl": "https://firebasestorage.googleapis.com/.../wave_alpha_2019_2023.png"
}
```

- `type`: chỉ 2 giá trị `"xe_so"` hoặc `"tay_ga"`.
- `yearFrom`/`yearTo`: khoảng đời ảnh đó áp dụng được (nhiều đời dùng chung 1 kiểu dáng thì gộp vào 1 document, đỡ tốn ảnh).
- Đặt tên field `brandLower`, `modelLower` (chữ thường, không dấu) để query không phân biệt hoa/thường — xem mục 3.

### Collection `vehicle_fallback` — ảnh dự phòng chung theo loại xe (chỉ cần 2 document)

```json
{ "type": "xe_so",  "imageUrl": "https://.../generic_xe_so.png" }
{ "type": "tay_ga", "imageUrl": "https://.../generic_tay_ga.png" }
```

### Ảnh thật lưu ở Firebase Storage, theo cấu trúc thư mục:

```
/vehicle_images/
  ├── honda/
  │   ├── wave_alpha_2019_2023.png
  │   ├── wave_alpha_2023_now.png
  │   ├── vision_2021_now.png
  │   └── air_blade_2020_now.png
  ├── yamaha/
  │   ├── sirius_2019_now.png
  │   └── exciter_2021_now.png
  └── fallback/
      ├── generic_xe_so.png
      └── generic_tay_ga.png
```

---

## 2. Model — `lib/models/vehicle_image_entry.dart`

```dart
class VehicleImageEntry {
  final String brand;
  final String model;
  final String type; // 'xe_so' | 'tay_ga'
  final int yearFrom;
  final int yearTo;
  final String imageUrl;

  VehicleImageEntry({
    required this.brand,
    required this.model,
    required this.type,
    required this.yearFrom,
    required this.yearTo,
    required this.imageUrl,
  });

  factory VehicleImageEntry.fromMap(Map<String, dynamic> map) => VehicleImageEntry(
    brand: map['brand'] ?? '',
    model: map['model'] ?? '',
    type: map['type'] ?? 'xe_so',
    yearFrom: map['yearFrom'] ?? 0,
    yearTo: map['yearTo'] ?? 9999,
    imageUrl: map['imageUrl'] ?? '',
  );
}
```

---

## 3. Service tra cứu ảnh — `lib/services/vehicle_image_service.dart`

Logic fallback 4 tầng đúng như đã thống nhất:
1. Khớp chính xác hãng + dòng + đời (năm nằm trong `[yearFrom, yearTo]`)
2. Khớp hãng + dòng, bỏ qua đời (lấy document đầu tiên khớp brand+model)
3. Khớp loại xe (`xe_so`/`tay_ga`) + hãng — lấy ảnh dòng nào đó cùng hãng cùng loại
4. Fallback cuối — ảnh generic theo loại xe (`vehicle_fallback`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_image_entry.dart';

class VehicleImageService {
  static final VehicleImageService instance = VehicleImageService._();
  VehicleImageService._();

  final _db = FirebaseFirestore.instance;

  // Cache RAM cho catalog, tránh query Firestore lại trong session hiện tại
  List<VehicleImageEntry>? _catalogCache;
  Map<String, String>? _fallbackCache;

  String _normalize(String s) => s.toLowerCase().trim();

  Future<List<VehicleImageEntry>> _loadCatalog() async {
    if (_catalogCache != null) return _catalogCache!;
    final snap = await _db.collection('vehicle_catalog').get();
    _catalogCache = snap.docs.map((d) => VehicleImageEntry.fromMap(d.data())).toList();
    return _catalogCache!;
  }

  Future<Map<String, String>> _loadFallback() async {
    if (_fallbackCache != null) return _fallbackCache!;
    final snap = await _db.collection('vehicle_fallback').get();
    _fallbackCache = {
      for (final d in snap.docs) (d.data()['type'] as String): (d.data()['imageUrl'] as String)
    };
    return _fallbackCache!;
  }

  /// Trả về URL ảnh phù hợp nhất cho 1 chiếc xe, theo thứ tự ưu tiên 4 tầng.
  Future<String> resolveImageUrl({
    required String brand,
    required String model,
    required String type, // 'xe_so' | 'tay_ga'
    required int year,
  }) async {
    final catalog = await _loadCatalog();
    final b = _normalize(brand);
    final m = _normalize(model);

    // Tầng 1: khớp chính xác brand + model + năm trong khoảng
    for (final e in catalog) {
      if (_normalize(e.brand) == b && _normalize(e.model) == m && year >= e.yearFrom && year <= e.yearTo) {
        return e.imageUrl;
      }
    }

    // Tầng 2: khớp brand + model, bỏ qua năm
    for (final e in catalog) {
      if (_normalize(e.brand) == b && _normalize(e.model) == m) {
        return e.imageUrl;
      }
    }

    // Tầng 3: khớp brand + type (loại xe), lấy bất kỳ dòng nào cùng hãng cùng loại
    for (final e in catalog) {
      if (_normalize(e.brand) == b && e.type == type) {
        return e.imageUrl;
      }
    }

    // Tầng 4: fallback generic theo loại xe
    final fallback = await _loadFallback();
    return fallback[type] ?? fallback['xe_so'] ?? '';
  }
}
```

---

## 4. Cache ảnh về máy — dùng package `cached_network_image`

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  cloud_firestore: ^5.4.0
  cached_network_image: ^3.4.1
```

Ở mọi nơi hiển thị ảnh xe (Home card, MyVehicleScreen), dùng `CachedNetworkImage` thay cho `Image.network` — tự động lưu cache lên đĩa, lần sau mở app đọc cache trước, không tải lại:

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.contain,
  placeholder: (context, url) => const SizedBox(
    width: 40, height: 40,
    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
  ),
  errorWidget: (context, url, error) => const Icon(Icons.two_wheeler, size: 60, color: Colors.white70),
  fadeInDuration: const Duration(milliseconds: 200),
)
```

> `cached_network_image` tự quản lý cache đĩa (qua `flutter_cache_manager` bên trong) — không cần code thêm logic lưu file thủ công. Ảnh đã tải sẽ hiện ngay lần sau dù không có mạng.

---

## 5. Nối vào `MyVehicleScreen` — khi người dùng nhập/sửa thông tin xe

Khi form "Sửa thông tin xe" lưu lại (hãng, dòng, năm sản xuất, loại xe), gọi `resolveImageUrl` rồi lưu URL kết quả vào hồ sơ xe (Firestore user's vehicle doc hoặc local store):

```dart
final imageUrl = await VehicleImageService.instance.resolveImageUrl(
  brand: 'Honda',
  model: 'Wave Alpha 110',
  type: 'xe_so',
  year: 2019,
);

// Lưu imageUrl vào VehicleProfile (model hồ sơ xe của người dùng)
vehicleProfile.imageUrl = imageUrl;
```

> Lưu ý: chỉ cần resolve 1 LẦN khi người dùng tạo/sửa thông tin xe — không cần query lại mỗi lần mở Home. Lưu thẳng `imageUrl` vào hồ sơ xe của người dùng (Firestore hoặc local), Home/MyVehicleScreen chỉ đọc field này ra để hiển thị.

---

## 6. Cập nhật Home Card — hiện ảnh xe thật thay icon

Sửa phần card xanh ở `home_screen.dart` (đúng vị trí trong ảnh bạn gửi — góc phải card "Đi chơi / Biển số / Tổng quãng đường"):

```dart
Container(
  // ... giữ nguyên decoration card xanh hiện tại ...
  child: Stack(children: [
    // ... giữ nguyên phần text "Đi chơi", biển số, tổng quãng đường bên trái ...
    Positioned(
      right: 8, bottom: 0,
      child: SizedBox(
        width: 130, height: 100,
        child: CachedNetworkImage(
          imageUrl: vehicleProfile.imageUrl ?? '',
          fit: BoxFit.contain,
          errorWidget: (_, __, ___) => const Icon(Icons.two_wheeler, size: 70, color: Colors.white54),
        ),
      ),
    ),
  ]),
)
```

---

## 7. Form chọn Hãng/Dòng/Năm — gợi ý UX để tự khớp đúng catalog

Để tránh người dùng gõ tự do dẫn đến sai chính tả (gây không khớp được tầng 1/2), nên cho **chọn từ danh sách có sẵn** thay vì gõ tay tự do:

- Field "Hãng xe": Dropdown/Autocomplete lấy danh sách brand duy nhất từ `vehicle_catalog` (Honda, Yamaha, Suzuki, Piaggio...) + thêm lựa chọn "Khác" ở cuối.
- Field "Dòng xe": Dropdown lọc theo Hãng đã chọn ở trên (chỉ hiện model thuộc hãng đó).
- Field "Năm sản xuất": vẫn để nhập số tự do (vì đời xe rất nhiều, không cần catalog hoá).
- Nếu người dùng chọn "Khác" ở Hãng (xe không phổ thông/không có trong catalog) → tự rơi vào tầng 3/4 fallback theo loại xe, không lỗi.

```dart
// Gợi ý field "Hãng xe" dùng Autocomplete có sẵn của Flutter
Autocomplete<String>(
  optionsBuilder: (textValue) {
    if (textValue.text.isEmpty) return _brandList;
    return _brandList.where((b) => b.toLowerCase().contains(textValue.text.toLowerCase()));
  },
  onSelected: (value) => setState(() => _selectedBrand = value),
)
```

---

## 8. Checklist

- [ ] Tạo collection `vehicle_catalog` trên Firestore, nhập dữ liệu các dòng xe phổ thông (Honda, Yamaha, Suzuki, Piaggio, VinFast điện...) kèm URL ảnh đã upload lên Storage
- [ ] Tạo collection `vehicle_fallback` với 2 document (`xe_so`, `tay_ga`)
- [ ] Cài `cloud_firestore` + `cached_network_image`, cấu hình Firebase project (`flutterfire configure`)
- [ ] `VehicleImageService.resolveImageUrl()` chạy đúng 4 tầng fallback, luôn trả về 1 URL hợp lệ (không bao giờ null/rỗng nếu fallback collection có dữ liệu)
- [ ] Form sửa thông tin xe: Hãng/Dòng dùng Autocomplete/Dropdown từ catalog, không gõ tự do để tránh sai khớp
- [ ] Khi lưu thông tin xe → gọi `resolveImageUrl` 1 lần, lưu kết quả vào hồ sơ xe, không gọi lại mỗi lần mở Home
- [ ] Home card và `MyVehicleScreen` dùng `CachedNetworkImage` hiện ảnh xe thật, có `errorWidget` fallback về icon `Icons.two_wheeler` nếu lỗi tải ảnh
- [ ] Test trường hợp mất mạng sau lần tải đầu — ảnh vẫn hiện từ cache, không bị trắng/lỗi

---

## 9. Lưu ý vận hành lâu dài

- Khi có dòng xe mới ra mắt hoặc cần bổ sung ảnh, chỉ cần: upload ảnh lên Storage + thêm 1 document vào `vehicle_catalog` trên Firebase Console — **không cần build lại app**, người dùng thấy ảnh mới ngay (sau khi cache catalog refresh, có thể set thời hạn cache catalog 24h bằng cách lưu kèm timestamp lúc tải).
- Nếu sau này muốn audit/sửa ảnh gen lỗi, dễ dàng thay ảnh trên Storage mà không ảnh hưởng code app.
- Nên backup danh sách `vehicle_catalog` ra file JSON định kỳ, đề phòng cần seed lại dữ liệu hoặc chuyển hạ tầng.

---

**Lưu ý cho AI code:** File này độc lập, không phụ thuộc các spec V2–V7 trước (khác mảng tính năng). Cần thiết lập Firebase project trước khi code (`flutterfire configure`), và cần có ảnh xe đã gen sẵn để upload lên Storage trước khi test.