#import "AxsQuyLuongCCSizeConfig.h"
#import "AxsQuyLuongCCSizePrivate.h"
#import <objc/runtime.h>

static AxsQuyLuongCCSizeLayoutSize axs_quyluongccsize_expand(AxsQuyLuongCCSizeLayoutSize size) {
    if (size.width == 1 && size.height == 1) return (AxsQuyLuongCCSizeLayoutSize){2, 2};
    return size;
}

%group AxsQuyLuongCCSizeSizing
%hook CCUIModuleSettingsManager
- (CCUIModuleSettings *)moduleSettingsForModuleIdentifier:(NSString *)identifier prototypeSize:(AxsQuyLuongCCSizeLayoutSize)size {
    CCUIModuleSettings *original = %orig;
    AxsQuyLuongCCSizeConfig *config = [AxsQuyLuongCCSizeConfig axs_quyluongccsize_shared];
    if (!original || ![identifier isKindOfClass:NSString.class] || ![config axs_quyluongccsize_isEnabled]) return original;
    id selected = [config axs_quyluongccsize_valueForKey:[@"module." stringByAppendingString:identifier] defaultValue:@NO];
    if (![selected isKindOfClass:NSNumber.class] || ![selected boolValue]) return original;
    if (![original respondsToSelector:@selector(layoutSizeForInterfaceOrientation:)] ||
        ![original respondsToSelector:@selector(doubleMarginForInterfaceOrientation:)] ||
        ![original respondsToSelector:@selector(initWithPortraitLayoutSize:landscapeLayoutSize:portraitDoubleMargin:landscapeDoubleMargin:)]) return original;
    AxsQuyLuongCCSizeLayoutSize portrait = [original layoutSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    AxsQuyLuongCCSizeLayoutSize landscape = [original layoutSizeForInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    AxsQuyLuongCCSizeLayoutSize expandedPortrait = axs_quyluongccsize_expand(portrait);
    AxsQuyLuongCCSizeLayoutSize expandedLandscape = axs_quyluongccsize_expand(landscape);
    if (portrait.width == expandedPortrait.width && portrait.height == expandedPortrait.height &&
        landscape.width == expandedLandscape.width && landscape.height == expandedLandscape.height) return original;
    // Never mutate Apple's cached settings: disabling must restore the original dimensions.
    return [[[original class] alloc] initWithPortraitLayoutSize:expandedPortrait landscapeLayoutSize:expandedLandscape
        portraitDoubleMargin:[original doubleMarginForInterfaceOrientation:UIInterfaceOrientationPortrait]
        landscapeDoubleMargin:[original doubleMarginForInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]] ?: original;
}
%end
%end

%group AxsQuyLuongCCSizeResolvedSizing
%hook CCUIModuleCollectionViewController
- (NSArray *)_sizesForModuleIdentifiers:(NSArray *)identifiers moduleInstanceByIdentifier:(NSDictionary *)instances interfaceOrientation:(NSInteger)orientation {
    NSArray *original = %orig;
    AxsQuyLuongCCSizeConfig *config = [AxsQuyLuongCCSizeConfig axs_quyluongccsize_shared];
    if (![config axs_quyluongccsize_isEnabled] || ![original isKindOfClass:NSArray.class] ||
        ![identifiers isKindOfClass:NSArray.class] || original.count != identifiers.count) return original;
    NSMutableArray *result = nil;
    for (NSUInteger index = 0; index < identifiers.count; index++) {
        NSString *identifier = identifiers[index];
        if (![identifier isKindOfClass:NSString.class]) continue;
        id selected = [config axs_quyluongccsize_valueForKey:[@"module." stringByAppendingString:identifier] defaultValue:@NO];
        if (![selected isKindOfClass:NSNumber.class] || ![selected boolValue]) continue;
        NSValue *value = original[index];
        if (![value isKindOfClass:NSValue.class]) continue;
        const char *type = value.objCType;
        // Match two unsigned integers, never interpret a CGSize as grid units.
        if (!type || type[0] != '{' || !strstr(type, "=QQ}")) continue;
        NSUInteger bytes = 0;
        NSGetSizeAndAlignment(type, &bytes, NULL);
        if (bytes != sizeof(AxsQuyLuongCCSizeLayoutSize)) continue;
        AxsQuyLuongCCSizeLayoutSize size;
        [value getValue:&size size:sizeof(size)];
        if (size.width != 1 || size.height != 1) continue;
        size = axs_quyluongccsize_expand(size);
        if (!result) result = [original mutableCopy];
        result[index] = [NSValue valueWithBytes:&size objCType:type];
    }
    return result ?: original;
}
%end
%end

%ctor {
    @autoreleasepool {
        NSOperatingSystemVersion os = NSProcessInfo.processInfo.operatingSystemVersion;
        if (os.majorVersion < 16 || os.majorVersion > 17) return;
        Class manager = NSClassFromString(@"CCUIModuleSettingsManager");
        Method method = class_getInstanceMethod(manager, @selector(moduleSettingsForModuleIdentifier:prototypeSize:));
        // Refuse unknown ABI rather than install a hook with a mismatched struct signature.
        if (!method) return;
        NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
        NSUInteger bytes = 0;
        if (sig.numberOfArguments != 4) return;
        const char *argType = [sig getArgumentTypeAtIndex:3];
        if (argType[0] != '{' || sig.methodReturnType[0] != '@') return;
        NSGetSizeAndAlignment(argType, &bytes, NULL);
        if (bytes != sizeof(AxsQuyLuongCCSizeLayoutSize)) return;
        [AxsQuyLuongCCSizeConfig axs_quyluongccsize_shared];
        %init(AxsQuyLuongCCSizeSizing);
        Class collection = NSClassFromString(@"CCUIModuleCollectionViewController");
        Method resolved = class_getInstanceMethod(collection, @selector(_sizesForModuleIdentifiers:moduleInstanceByIdentifier:interfaceOrientation:));
        if (resolved) {
            NSMethodSignature *rs = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(resolved)];
            if (rs.numberOfArguments == 5 && rs.methodReturnType[0] == '@' &&
                [rs getArgumentTypeAtIndex:2][0] == '@' && [rs getArgumentTypeAtIndex:3][0] == '@' &&
                [rs getArgumentTypeAtIndex:4][0] == 'q') {
                %init(AxsQuyLuongCCSizeResolvedSizing);
            }
        }
    }
}
