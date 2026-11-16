#pragma once
#import <UIKit/UIKit.h>
typedef struct { NSUInteger width; NSUInteger height; } AxsQuyLuongCCSizeLayoutSize;
@interface CCUIModuleSettings : NSObject
- (AxsQuyLuongCCSizeLayoutSize)layoutSizeForInterfaceOrientation:(NSInteger)orientation;
- (BOOL)doubleMarginForInterfaceOrientation:(NSInteger)orientation;
- (instancetype)initWithPortraitLayoutSize:(AxsQuyLuongCCSizeLayoutSize)portrait landscapeLayoutSize:(AxsQuyLuongCCSizeLayoutSize)landscape portraitDoubleMargin:(BOOL)p landscapeDoubleMargin:(BOOL)l;
@end
@interface CCUIModuleSettingsManager : NSObject
- (CCUIModuleSettings *)moduleSettingsForModuleIdentifier:(NSString *)identifier prototypeSize:(AxsQuyLuongCCSizeLayoutSize)size;
@end
