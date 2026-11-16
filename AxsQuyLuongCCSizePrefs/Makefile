include ../AxsQuyLuongCCSizeBuild.mk
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AxsQuyLuongCCSizePrefs
AxsQuyLuongCCSizePrefs_FILES = $(wildcard *.m)
AxsQuyLuongCCSizePrefs_CFLAGS = -fobjc-arc -I../Sources
AxsQuyLuongCCSizePrefs_FRAMEWORKS = UIKit Foundation CoreFoundation
AxsQuyLuongCCSizePrefs_PRIVATE_FRAMEWORKS = Preferences
AxsQuyLuongCCSizePrefs_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk
