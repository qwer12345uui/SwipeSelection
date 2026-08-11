#import "SSPanGestureRecognizer.h"

// ---- 私有类声明（仅声明本文件用到的选择器；仅用于本编译单元）----
@interface UIKBKey : NSObject
-(NSString *)representedString;
-(NSString *)name;
@end

@interface UIKeyboardLayoutStar : UIView
-(id)keyHitTestWithoutCharging:(CGPoint)arg1;
@end

@interface UIKeyboardImpl : UIView
-(id)_layout;
@end

@implementation SSPanGestureRecognizer

// 2.6 修复：点击 "123"（More）等控制键无效（有高亮/触摸标记但不触发）。
// 根因：UIPanGestureRecognizer 的 delaysTouchesEnded 默认为 YES —— 手指抬起后，
// 键盘视图要等本识别器判定失败才能收到 touchesEnded。字母键在“按下”时已完成输入，
// 所以不受影响；而 123 这类控制键在“抬起”时才触发键盘平面切换，touchesEnded 被
// 扣住/延迟后切换动作就丢了。这里显式关闭两个 delay，让触摸投递完全即时。
-(instancetype)initWithTarget:(id)target action:(SEL)action {
	self = [super initWithTarget:target action:action];
	if (self) {
		self.delaysTouchesBegan = NO;
		self.delaysTouchesEnded = NO;
	}
	return self;
}

// 2.6 修复：触摸起点落在控制键（123/More、Delete、Shift、地球仪、Return 等）上时
// 不启动滑动手势，把控制键完整交还给键盘自己处理。同时恢复 iOS 自带的
// “按住 123 滑动选数字”手势（否则滑动开始后 touches 会被本识别器 cancel）。
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	@try {
		UIView *v = [self view];
		if ([v respondsToSelector:@selector(_layout)]) {
			id layout = [(UIKeyboardImpl *)v _layout];
			if ([layout respondsToSelector:@selector(keyHitTestWithoutCharging:)]) {
				CGPoint point = [gestureRecognizer locationInView:(UIView *)layout];
				UIKBKey *key = [(UIKeyboardLayoutStar *)layout keyHitTestWithoutCharging:point];
				NSString *rs = [[key representedString] lowercaseString];
				NSString *nm = [[key name] lowercaseString];

				static NSSet *controlKeys = nil;
				static dispatch_once_t onceToken;
				dispatch_once(&onceToken, ^{
					controlKeys = [NSSet setWithArray:@[
						@"more", @"delete", @"shift", @"international",
						@"return", @"dictate", @"emoji", @"globe",
						@"123", @"abc", @"#+="
					]];
				});

				if ((rs && [controlKeys containsObject:rs]) ||
				    (nm && [controlKeys containsObject:nm])) {
					return NO;
				}
			}
		}
	}
	@catch (NSException *exception) {}
	return YES;
}

-(BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
	if ([preventingGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && (![NSStringFromClass([preventingGestureRecognizer class]) isEqualToString:@"AKFlickGestureRecognizer"])) {
		return YES;
	}
	return NO;
}

-(BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
	return NO;
}
@end
