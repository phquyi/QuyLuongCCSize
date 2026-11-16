#import "AxsQuyLuongCCSizeConfig.h"
#import "AxsQuyLuongCCSizePreferences.h"

@interface AxsQuyLuongCCSizeConfig ()
@property (atomic, copy) NSDictionary *snapshot;
@property (nonatomic, strong) dispatch_queue_t reloadQueue;
@end

static void axs_quyluongccsize_preferencesDidChange(CFNotificationCenterRef center, void *observer,
                                          CFStringRef name, const void *object, CFDictionaryRef info) {
    AxsQuyLuongCCSizeConfig *config = (__bridge AxsQuyLuongCCSizeConfig *)observer;
    dispatch_async(config.reloadQueue, ^{
        [config axs_quyluongccsize_reload];
    });
}

@implementation AxsQuyLuongCCSizeConfig

+ (instancetype)axs_quyluongccsize_shared {
    static AxsQuyLuongCCSizeConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reloadQueue = dispatch_queue_create("com.quyluong.ccsize.preferences", DISPATCH_QUEUE_SERIAL);
        [self axs_quyluongccsize_reload];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            (__bridge const void *)self, axs_quyluongccsize_preferencesDidChange,
            (__bridge CFStringRef)AxsQuyLuongCCSizePreferencesChanged, NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately);
        // Close the window between the first read and observer registration.
        dispatch_async(_reloadQueue, ^{ [self axs_quyluongccsize_reload]; });
    }
    return self;
}

- (void)axs_quyluongccsize_reload {
    self.snapshot = axs_quyluongccsize_readPreferences();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AxsQuyLuongCCSizePreferencesChanged object:self];
    });
}

- (id)axs_quyluongccsize_valueForKey:(NSString *)key defaultValue:(id)defaultValue {
    return self.snapshot[key] ?: defaultValue;
}

- (BOOL)axs_quyluongccsize_isEnabled {
    id value = [self axs_quyluongccsize_valueForKey:@"enabled" defaultValue:@(NO)];
    return [value isKindOfClass:[NSNumber class]] ? [value boolValue] : NO;
}

- (void)dealloc {
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                            (__bridge const void *)self);
}

@end
