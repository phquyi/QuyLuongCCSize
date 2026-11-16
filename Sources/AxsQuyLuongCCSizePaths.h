#pragma once

#import <Foundation/Foundation.h>

// Linux clang may accept arm64e yet emit ordinary arm64. Do not ship that as arm64e.
#if defined(__arm64e__) && !__has_feature(ptrauth_calls)
#error "arm64e requires an Apple toolchain with pointer authentication support; use macOS/Xcode."
#endif

#ifdef THEOS_PACKAGE_SCHEME_ROOTHIDE
#import <roothide.h>
#else
#import <rootless.h>
#endif

static inline NSString *axs_quyluongccsize_resourcePath(NSString *rootfsPath) {
#ifdef THEOS_PACKAGE_SCHEME_ROOTHIDE
    return jbroot(rootfsPath);
#else
    return ROOT_PATH_NS_VAR(rootfsPath);
#endif
}

static inline NSString *axs_quyluongccsize_preferencesPath(void) {
    NSString *path = @"/var/mobile/Library/Preferences/com.quyluong.ccsize.plist";
#ifdef THEOS_PACKAGE_SCHEME_ROOTHIDE
    return jbroot(path);
#else
    // Mobile user preferences do not use the rootless installation prefix.
    return path;
#endif
}
