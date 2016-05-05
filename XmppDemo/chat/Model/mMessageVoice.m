//
//  mMessageVoice.m
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import "mMessageVoice.h"
#import "mMessageVoice.h"
#import "mMessageImage.h"

@implementation mMessageVoice

-(instancetype)initDictionary:(NSDictionary *)dictionary
{
    if(self ==[super init])
    {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (instancetype)initWithVoiceUrl:(NSString *)mVoiceUrl andTimeLength:(NSInteger)mTimeLength {
    if (self == [super init]) {
        self.voiceUrl = mVoiceUrl;
        self.timeLength = mTimeLength;
    }
    return self;
}

@end
