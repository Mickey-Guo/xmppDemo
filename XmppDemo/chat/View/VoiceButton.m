//
//  ContentButton.m
//  chat
//
//  Created by yinxiufeng on 15/5/25.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "VoiceButton.h"



@implementation VoiceButton



#pragma mark 重新设置 图标 和  文字 frame
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.iconFrame;
    self.titleLabel.frame = self.textFrame;
}

@end
