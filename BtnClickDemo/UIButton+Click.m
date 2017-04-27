//
//  UIButton+Click.m
//
//  Created by Paddy on 17/4/10.
//  Copyright © 2017年 lpc. All rights reserved.
//

#import "UIButton+Click.h"
#import <objc/runtime.h>

static const char *k_ignoreEvent = "k_ignoreEvent";
static const char *k_forbidden_AvoidRepeatClick = "k_forbidden_AvoidRepeatClick";
static float k_acceptEventInterval = 1.0; //Btn间隔时间

@interface UIButton ()
@property (nonatomic,assign) BOOL BTN_ignoreEvent;
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


#pragma mark -- ignoreEvent --
- (BOOL)BTN_ignoreEvent{
    return [objc_getAssociatedObject(self, k_ignoreEvent) boolValue];
}

-(void)setBTN_ignoreEvent:(BOOL)BTN_ignoreEvent{
    objc_setAssociatedObject(self, k_ignoreEvent, @(BTN_ignoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -- 是否禁止防重 --
- (BOOL)BTN_forbidden_AvoidRepeatClick{
    return [objc_getAssociatedObject(self, k_forbidden_AvoidRepeatClick) boolValue];
}

- (void)setBTN_forbidden_AvoidRepeatClick:(BOOL)BTN_forbidden_AvoidRepeatClick{
    objc_setAssociatedObject(self, k_forbidden_AvoidRepeatClick, @(BTN_forbidden_AvoidRepeatClick), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -- sendAction --
- (void)__BTN_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (self.BTN_forbidden_AvoidRepeatClick) {
        //禁止防重->直接调用
        [self __BTN_sendAction:action to:target forEvent:event];
    }
    else{
        //开启防重功能
        if (self.BTN_ignoreEvent){
            //如果忽略此次事件,则直接结束
            return;
        }
        
        if (k_acceptEventInterval > 0) {
            self.BTN_ignoreEvent = YES;
            [self performSelector:@selector(setBTN_ignoreEvent:) withObject:@(NO) afterDelay:k_acceptEventInterval];
        }
        [self __BTN_sendAction:action to:target forEvent:event];
    }
}

@end
