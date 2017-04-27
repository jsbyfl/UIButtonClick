//
//  ViewController.m
//  BtnClickDemo
//
//  Created by Paddy on 17/4/20.
//  Copyright © 2017年 Paddy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (weak, nonatomic) IBOutlet UITextView *myTextV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateButtonTitle];
}


- (IBAction)leftBtnClick:(id)sender {
    
    NSString *string = [self.myTextV.text stringByAppendingString:@" 增加的字符"];
    self.myTextV.text = string;
    NSLog(@"%@",string);
}

- (IBAction)clearBtnAct:(id)sender {
    self.myTextV.text = nil;
}

- (IBAction)rightBtnClick:(id)sender {
    [self.view endEditing:YES];
    
    self.leftBtn.BTN_forbidden_AvoidRepeatClick = !self.leftBtn.BTN_forbidden_AvoidRepeatClick;
    [self updateButtonTitle];
}

- (void)updateButtonTitle
{
    NSString *title = nil;
    if (self.leftBtn.BTN_forbidden_AvoidRepeatClick) {
        title = @"防重复点击";
    }else{
        title = @"正常点击";
    }
    [self.rightBtn setTitle:title forState:UIControlStateNormal];
}

@end
