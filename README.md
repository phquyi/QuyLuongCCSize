# quyluong - CC Size 0.1.0

Tác giả: **quyluong**. Package: `com.quyluong.ccsize`.

Tweak dành cho thiết bị jailbreak iOS 16–17, có cấu hình Rootless và Roothide. Mỗi công tắc chọn một mô-đun để đổi kích thước lưới từ 1×1 lên 2×2 trong cả bố cục dọc/ngang nếu kích thước gốc là 1×1. Tắt công tắc trả về cách bố trí gốc sau khi áp dụng. Các ô gốc lớn hơn không bị đổi. Không phóng to biểu tượng bằng transform, không thay đổi chức năng chạm/nhấn giữ của mô-đun.

## Sử dụng

1. Cài deb đúng môi trường bằng Sileo/Zebra và Respring.
2. Vào Cài đặt → quyluong - CC Size.
3. Bật tweak rồi bật các mô-đun muốn dùng 2×2.
4. Nhấn Áp dụng / Respring. Nếu sbreload không có hoặc không được phép chạy, Respring từ ứng dụng jailbreak.
5. Tắt từng công tắc hoặc tắt tweak rồi Respring để trở về mặc định.

Công tắc ở đây bật/tắt việc phóng kích thước. Để thêm/ẩn hẳn một mô-đun khỏi Control Centre, dùng Cài đặt → Trung tâm điều khiển.

Danh sách quét Info.plist của các bundle trong `/System/Library/ControlCenter/Bundles` và thư mục `/Library/ControlCenter/Bundles` đã chuyển đường dẫn bằng API jailbreak. Không nạp mã từ bundle. Một số mô-đun chỉ có định danh qua provider không có bundle riêng có thể không xuất hiện. Tên mô-đun phụ thuộc tài nguyên ngôn ngữ của iOS.

## Tình trạng kiểm chứng

- Đã biên dịch và kiểm tra deb Rootless **arm64**, đúng đường dẫn `/var/jb`, tác giả và gói Preferences.
- Chưa thử cài hoặc chạy trên thiết bị jailbreak; chưa xác nhận tương thích mọi bản iOS 16.x/17.x hoặc mọi tweak thay bố cục khác.
- Alpine clang cục bộ nhận cờ arm64e nhưng tạo Mach-O ARM64 ALL. Gói thử Roothide đó không được bàn giao làm bản cài. Source có chặn arm64e thiếu ptrauth để tránh lặp lại lỗi.
- Rootless arm64 không được coi là bản đã xác minh cho SpringBoard arm64e trên thiết bị A12 trở lên. Với máy arm64e, hãy biên dịch source bằng Apple clang để có slice arm64e chuẩn.
- Workflow GitHub Actions sử dụng macOS/Xcode và roothide/theos để build Rootless + Roothide. Workflow chưa được chạy trong lần bàn giao này.

## Build

Cần Theos, iPhoneOS16.5.sdk và Apple clang có hỗ trợ arm64e. Roothide cần roothide/theos cùng header/libroothide đúng môi trường.

```sh
export THEOS="$HOME/theos"
sh build.sh rootless
sh build.sh roothide
```

Mặc định build arm64 và arm64e. Đầu ra trong `packages/`. Không đổi Architecture của deb để giả lập một môi trường khác.

Có thể đưa toàn bộ source lên repository GitHub và chạy workflow **Build CC Size** trong tab Actions; workflow chỉ upload artifacts, không tự phát hành Release.

## Thiết kế và kiểm thử trên máy

Hook `CCUIModuleSettingsManager` trả về settings riêng, không sửa cache hệ thống. Hook `_sizesForModuleIdentifiers:moduleInstanceByIdentifier:interfaceOrientation:` bổ sung trường hợp mô-đun tự báo kích thước. Các hook kiểm tra class/selector/chữ ký trước khi cài; dữ liệu kích thước dùng hai unsigned integer 64 bit, không dùng CGSize.

Sau khi cài cần kiểm tra: bật/tắt tổng; bật một mô-đun trong khi mô-đun khác giữ 1×1; đổi hướng; cuộn CC; nhấn/nhấn giữ; Respring; gỡ tweak; phối hợp CCSupport hoặc tweak CC khác. Icon của mô-đun có thể vẫn giữ kích thước do thiết kế của chính mô-đun.

Tham khảo chữ ký API công khai:
- https://github.com/MTACS/iOS-17-Runtime-Headers/tree/main/PrivateFrameworks/ControlCenterUI.framework
- https://github.com/opa334/CCSupport/blob/master/Tweak.xm
