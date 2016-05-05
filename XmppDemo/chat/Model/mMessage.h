//
//  mMessage.h
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GQStatic.h"


//图片消息
@class mMessageImage;
//语音消息
@class mMessageVoice;

@interface mMessage : NSObject
//发送时间
@property(nonatomic,strong)NSString *dateTime;
//发送内容
@property(nonatomic,strong)NSString *msg;
//接收类型(发送、接受)
@property(nonatomic,assign)SendType sendType;
//消息内容(图片消息，文字消息，语音消息)
@property(nonatomic,assign)MessageType messageType;
//图片消息
@property(nonatomic,strong)mMessageImage *messageImage;
//语音消息
@property(nonatomic,strong)mMessageVoice *messageVoice;
//是否隐藏发送时间
@property(nonatomic,assign)BOOL hiddenDateTime;

-(instancetype)initDictionary:(NSDictionary *)dictionary;

@end
