# iOS 15+ RootHide build (requires roothide/theos toolchain)
# IMPORTANT: SDK is pinned to the patched iPhoneOS16.5.sdk.
# Do NOT use "latest" here — on modern macOS runners that resolves to the
# newest Xcode SDK (e.g. iPhoneOS26.x), whose toolchain emits arm64e ObjC
# metadata/pointer-auth that iOS 15.0's libobjc cannot authenticate:
# every process crashed at injection time (dyld -> libinjector -> libobjc
# reading the dylib's __DATA) = SpringBoard Safe Mode / instant app crash.
THEOS_PACKAGE_SCHEME = roothide
ARCHS = arm64e
TARGET = iphone:clang:16.5:15.0

TWEAK_NAME = SwipeSelection
SwipeSelection_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value
SwipeSelection_FILES = Tweak.xm SSPanGestureRecognizer.m
SwipeSelection_FRAMEWORKS = UIKit Foundation CoreGraphics

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
