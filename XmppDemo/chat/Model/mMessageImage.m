//
//  mMessageImage.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "mMessageImage.h"

@implementation mMessageImage

-(instancetype)initDictionary:(NSDictionary *)dictionary
{
    if(self ==[super init])
    {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithImageUrl:(NSString *)imageUrl andSize:(CGSize)imageSize {
    if (self == [super init]) {
        self.imageUrl = [imageUrl copy];
        self.width = imageSize.width;
        self.height = imageSize.height;
    }
    return self;
}


@end
