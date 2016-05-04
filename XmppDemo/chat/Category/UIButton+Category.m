//
//  UIButton+Category.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "UIButton+Category.h"

@implementation UIButton (Category)


#pragma mark 聊天工具条上的按钮处理
+(instancetype)initWithFrame:(CGRect)frame normal:(UIImage *)normal highLighted:(UIImage *)highLighted
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:normal forState:UIControlStateNormal];
    [btn setBackgroundImage:highLighted forState:UIControlStateHighlighted];
    btn.frame = frame;
    return btn;
}

@end
