//
//  NSString+Category.h
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Category)

#pragma mark 计算文字宽度和高度
- (CGSize)sizeWithMaxSize:(CGSize)maxSize fontSize:(CGFloat)fontSize;

@end
