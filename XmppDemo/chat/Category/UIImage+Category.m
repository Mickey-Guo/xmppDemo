//
//  UIImage+Category.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)


+(instancetype)stretchableImage:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    image  = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    return image;
}



@end
