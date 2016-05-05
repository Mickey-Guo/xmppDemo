//
//  mMessage.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "mMessage.h"


@implementation mMessage


-(instancetype)initDictionary:(NSDictionary *)dictionary
{
    if(self ==[super init])
    {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithSendType:(SendType)mSendType andDateTime:(NSString *)mDateTime {
    if (self = [super init]) {
        self.sendType = mSendType;
        self.dateTime = mDateTime;
    }
    return self;
}




@end
