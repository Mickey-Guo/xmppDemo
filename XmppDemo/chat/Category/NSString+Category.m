//
//  NSString+Category.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

#pragma mark 计算文字宽度和高度
- (CGSize)sizeWithMaxSize:(CGSize)maxSize fontSize:(CGFloat)fontSize
{
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
}

@end
