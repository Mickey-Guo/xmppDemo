//
//  mMessageVoice.h
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mMessageVoice : NSObject

//语音的服务器地址
@property(nonatomic,strong)NSString *voiceUrl;
//语音时长
@property(nonatomic,assign)NSInteger timeLength;

-(instancetype)initDictionary:(NSDictionary *)dictionary;

@end
