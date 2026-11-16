DEBUG = 0
FINALPACKAGE = 1

ARCHS = arm64 arm64e

# Share the SDK and deployment targets with the PreferenceBundle.
include AxsQuyLuongCCSizeBuild.mk
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AxsQuyLuongCCSize
AxsQuyLuongCCSize_FILES = $(wildcard Hooks/*.xm Sources/*.m)
AxsQuyLuongCCSize_CFLAGS = -fobjc-arc -I./Headers -I./Sources
AxsQuyLuongCCSize_FRAMEWORKS = UIKit Foundation CoreFoundation
AxsQuyLuongCCSize_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += AxsQuyLuongCCSizePrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
