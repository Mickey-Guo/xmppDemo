//
//  ImageButton.m
//  chat
//
//  Created by yinxiufeng on 15/5/25.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "ImageButton.h"

@implementation ImageButton

#pragma mark 重写图片布局
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.imageFrame;
    
    //设置图片圆角
    self.imageView.layer.cornerRadius = 10;
    self.imageView.layer.masksToBounds = YES;

}

@end
