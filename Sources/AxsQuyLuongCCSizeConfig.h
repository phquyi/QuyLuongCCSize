#pragma once

#import <Foundation/Foundation.h>

@interface AxsQuyLuongCCSizeConfig : NSObject
+ (instancetype)axs_quyluongccsize_shared;
- (BOOL)axs_quyluongccsize_isEnabled;
- (id)axs_quyluongccsize_valueForKey:(NSString *)key defaultValue:(id)defaultValue;
- (void)axs_quyluongccsize_reload;
@end
