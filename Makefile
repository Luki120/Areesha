ARCHS = arm64
TARGET = iphone:clang:latest:15.0

INSTALL_TARGET_PROCESSES = Areesha
APPLICATION_NAME = Areesha

rwildcard = $(foreach d, $(wildcard $(1:=/*)), $(call rwildcard, $d, $2) $(filter $(subst *, %, $2), $d))

Areesha_FILES = $(call rwildcard, Sources, *.swift)
Areesha_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
