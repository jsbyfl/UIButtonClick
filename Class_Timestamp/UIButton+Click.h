//
//  UIButton+Click.h
//
//  Created by Paddy on 17/4/10.
//  Copyright © 2017年 lpc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 按钮点击防重 (默认开启)
 */
@interface UIButton (Click)

@property (nonatomic,assign) BOOL BTN_forbidden_AvoidRepeatClick; //是否禁止防重(Default NO)

@end
