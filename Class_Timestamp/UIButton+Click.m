//
//  UIButton+Click.m
//
//  Created by Paddy on 17/4/10.
//  Copyright © 2017年 lpc. All rights reserved.
//

#import "UIButton+Click.h"
#import <objc/runtime.h>

static const char *kAcceptEventTime = "kAcceptEventTime";
static const char *kForbidden_AvoidRepeatClick = "kForbidden_AvoidRepeatClick";
static float kAcceptEventInterval = 1.0; //Btn间隔时间

@interface UIButton ()
@property (nonatomic,assign) NSTimeInterval BTN_acceptEventTime; //接收事件的时间戳
@end

@implementation UIButton (Click)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(sendAction:to:forEvent:);
        SEL swizzledSelector = @selector(__BTN_sendAction:to:forEvent:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


#pragma mark -- acceptEventTime --
- (NSTimeInterval)BTN_acceptEventTime{
    return [objc_getAssociatedObject(self, kAcceptEventTime) doubleValue];
}

- (void)setBTN_acceptEventTime:(NSTimeInterval)BTN_acceptEventTime{
    objc_setAssociatedObject(self, kAcceptEventTime, @(BTN_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -- 是否禁止防重 --
- (BOOL)BTN_forbidden_AvoidRepeatClick{
    return [objc_getAssociatedObject(self, kForbidden_AvoidRepeatClick) boolValue];
}

- (void)setBTN_forbidden_AvoidRepeatClick:(BOOL)BTN_forbidden_AvoidRepeatClick{
    objc_setAssociatedObject(self, kForbidden_AvoidRepeatClick, @(BTN_forbidden_AvoidRepeatClick), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -- sendAction --
- (void)__BTN_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (self.allControlEvents != UIControlEventTouchUpInside) {
        //多个事件,不做防重处理
        [self __BTN_sendAction:action to:target forEvent:event];
        return;
    }
    
    if (self.BTN_forbidden_AvoidRepeatClick) {
        //禁止防重->直接调用
        [self __BTN_sendAction:action to:target forEvent:event];
        return;
    }
    else{
        //开启防重功能
        double first = event.timestamp;
        double second = self.BTN_acceptEventTime;
        NSLog(@"%f %f %f",second,first,second-first);
        
        if (event.timestamp - self.BTN_acceptEventTime < kAcceptEventInterval) {
            return;
        }
        self.BTN_acceptEventTime = event.timestamp;

        [self __BTN_sendAction:action to:target forEvent:event];
    }
}

@end
