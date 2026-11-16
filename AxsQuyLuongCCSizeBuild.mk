DEBUG ?= 0
FINALPACKAGE ?= 1
ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:16.0
ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
ADDITIONAL_LIBRARIES += roothide
endif
