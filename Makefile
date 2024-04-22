ARCHS = arm64
TARGET = iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = Areesha
APPLICATION_NAME = Areesha

rwildcard = $(foreach d, $(wildcard $(1:=/*)), $(call rwildcard, $d, $2) $(filter $(subst *, %, $2), $d))

Areesha_FILES = $(call rwildcard, Sources, *.swift)
Areesha_LDFLAGS = -rpath /Applications/Areesha.app/Frameworks/
Areesha_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk

before-stage::
	@mkdir -p $(THEOS_STAGING_DIR)/Applications/Areesha.app/Frameworks/
	@cp $(THEOS)/toolchain/linux/iphone/lib/swift-5.5/iphoneos/libswift_Concurrency.dylib $(THEOS_STAGING_DIR)/Applications/Areesha.app/Frameworks/libswift_Concurrency.dylib
