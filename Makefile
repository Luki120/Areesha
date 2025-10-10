ARCHS = arm64
UNAME := $(shell uname)

ifeq ($(UNAME), Linux)	
	export TARGET := iphone:clang:15.6:14.0
endif

ifeq ($(UNAME), Darwin)
	export SYSROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.0.sdk
	export TARGET := iphone:clang:latest:14.0
endif

INSTALL_TARGET_PROCESSES = Areesha
APPLICATION_NAME = Areesha

rwildcard = $(foreach d, $(wildcard $(1:=/*)), $(call rwildcard, $d, $2) $(filter $(subst *, %, $2), $d))

Areesha_FILES = $(call rwildcard, Sources, *.swift)
Areesha_LDFLAGS = -rpath /Applications/Areesha.app/Frameworks/
Areesha_FRAMEWORKS = UIKit CoreGraphics
Areesha_SWIFTFLAGS = -swift-version 6
Areesha_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk

before-stage::
	@mkdir -p $(THEOS_STAGING_DIR)/Applications/Areesha.app/Frameworks/
	@cp $(THEOS)/toolchain/linux/iphone/lib/swift-5.5/iphoneos/libswift_Concurrency.dylib $(THEOS_STAGING_DIR)/Applications/Areesha.app/Frameworks/libswift_Concurrency.dylib
