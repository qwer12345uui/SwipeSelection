# iOS 15+ RootHide build (requires roothide/theos toolchain)
THEOS_PACKAGE_SCHEME = roothide
ARCHS = arm64e
TARGET = iphone:clang:latest:15.0

TWEAK_NAME = SwipeSelection
SwipeSelection_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value
SwipeSelection_FILES = Tweak.xm SSPanGestureRecognizer.m
SwipeSelection_FRAMEWORKS = UIKit Foundation CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
