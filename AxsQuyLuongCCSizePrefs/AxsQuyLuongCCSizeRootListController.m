#import "AxsQuyLuongCCSizeRootListController.h"
#import "AxsQuyLuongCCSizePreferences.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import <spawn.h>
#import <unistd.h>
extern char **environ;

@implementation AxsQuyLuongCCSizeRootListController

- (void)axs_quyluongccsize_alert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (PSSpecifier *)axs_quyluongccsize_switch:(NSString *)name key:(NSString *)key {
    PSSpecifier *item = [PSSpecifier preferenceSpecifierNamed:name target:self
        set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:)
        detail:nil cell:PSSwitchCell edit:nil];
    [item setProperty:key forKey:@"key"];
    [item setProperty:@NO forKey:@"default"];
    return item;
}

- (NSMutableArray *)specifiers {
    if (_specifiers) return _specifiers;
    self.title = @"quyluong - CC Size";
    NSMutableArray *items = [NSMutableArray array];
    PSSpecifier *header = [PSSpecifier preferenceSpecifierNamed:@"quyluong - CC Size" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [header setProperty:@"Tác giả: quyluong • iOS 16–17\nBật từng mô-đun để đổi ô 1×1 thành 2×2. Tắt để dùng kích thước gốc. Sau khi thay đổi, nhấn Áp dụng / Respring." forKey:@"footerText"];
    [items addObject:header];
    [items addObject:[self axs_quyluongccsize_switch:@"Bật tweak" key:@"enabled"]];
    PSSpecifier *apply = [PSSpecifier preferenceSpecifierNamed:@"Áp dụng / Respring" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
    apply.buttonAction = @selector(axs_quyluongccsize_apply:);
    [items addObject:apply];
    PSSpecifier *group = [PSSpecifier preferenceSpecifierNamed:@"Phóng mô-đun lên 2×2" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [group setProperty:@"Danh sách gồm các mô-đun hệ thống và mô-đun jailbreak tìm thấy trên máy. Chỉ ô gốc 1×1 bị đổi kích thước; ô lớn hơn được giữ nguyên. Thêm hoặc ẩn mô-đun trong Cài đặt → Trung tâm điều khiển." forKey:@"footerText"];
    [items addObject:group];
    NSMutableDictionary<NSString *, NSString *> *modules = [NSMutableDictionary dictionary];
    NSArray *directories = @[@"/System/Library/ControlCenter/Bundles", axs_quyluongccsize_resourcePath(@"/Library/ControlCenter/Bundles")];
    for (NSString *directory in directories) {
        for (NSString *entry in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil]) {
            NSString *path = [directory stringByAppendingPathComponent:entry];
            NSBundle *bundle = [NSBundle bundleWithPath:path];
            NSString *identifier = bundle.bundleIdentifier;
            if (!identifier.length) continue;
            NSDictionary *info = bundle.localizedInfoDictionary ?: bundle.infoDictionary;
            NSString *name = info[@"CFBundleDisplayName"] ?: info[@"CFBundleName"] ?: identifier;
            if (![name isKindOfClass:NSString.class]) name = identifier;
            NSString *localized = [bundle localizedStringForKey:@"CFBundleDisplayName" value:name table:@"InfoPlist"];
            modules[identifier] = localized.length ? localized : name;
        }
    }
    // Retain selections for temporarily unavailable third-party modules.
    for (NSString *key in axs_quyluongccsize_readPreferences()) {
        if ([key hasPrefix:@"module."]) {
            NSString *identifier = [key substringFromIndex:7];
            if (identifier.length && !modules[identifier]) modules[identifier] = identifier;
        }
    }
    NSArray *identifiers = [modules.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [modules[a] localizedStandardCompare:modules[b]];
    }];
    for (NSString *identifier in identifiers) {
        [items addObject:[self axs_quyluongccsize_switch:modules[identifier] key:[@"module." stringByAppendingString:identifier]]];
    }
    if (!identifiers.count) {
        PSSpecifier *empty = [PSSpecifier preferenceSpecifierNamed:@"Chưa tìm thấy mô-đun" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [empty setProperty:@"Kiểm tra quyền đọc thư mục ControlCenter/Bundles và khởi động lại Cài đặt." forKey:@"footerText"];
        [items addObject:empty];
    }
    _specifiers = items;
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    return axs_quyluongccsize_readPreferences()[[specifier propertyForKey:@"key"]] ?: [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSError *error = nil;
    if (!axs_quyluongccsize_writePreference([specifier propertyForKey:@"key"], value, &error)) {
        [self axs_quyluongccsize_alert:@"Không lưu được" message:error.localizedDescription ?: @"Kiểm tra quyền ghi cấu hình."];
        [self reloadSpecifiers];
    }
}

- (void)axs_quyluongccsize_apply:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Áp dụng thay đổi?" message:@"Respring sẽ khởi động lại giao diện SpringBoard." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Huỷ" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *tool = axs_quyluongccsize_resourcePath(@"/usr/bin/sbreload");
        if (access(tool.fileSystemRepresentation, X_OK) != 0) {
            [self axs_quyluongccsize_alert:@"Respring thủ công" message:@"Hãy dùng nút Respring trong ứng dụng jailbreak để áp dụng thay đổi."];
            return;
        }
        pid_t pid;
        const char *path = tool.fileSystemRepresentation;
        char *args[] = {(char *)path, NULL};
        int result = posix_spawn(&pid, path, NULL, NULL, args, environ);
        if (result != 0) [self axs_quyluongccsize_alert:@"Không thể Respring" message:@"Hãy Respring từ ứng dụng jailbreak."];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
