//
//  GQStatic.h
//  XmppDemo
//
//  Created by guoqing on 16/4/14.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQAppDelegate.h"
#pragma mark 接收类型
typedef enum{
    
    Send,
    Receive
    
} SendType;

#pragma mark 消息类型
typedef enum
{
    MsgText,
    MsgImage,
    MsgVoice
}
MessageType;

static NSString *USERID = @"userId";
static NSString *PASS= @"pass";
static NSString *SERVER = @"server";
static NSString *SOURCE = @"source";
static NSString *HOSTNAME = @"xmpp.test";

static NSString *PASSWORD_ERROR = @"Your password is wrong. Please input again.";
static NSString *CONNECT_FAILED = @"Failed to connect the server. Please try again.";
static NSString *OK = @"OK";
static NSString *WARNING = @"Warining";
static float padding = 20;

static NSString *STREAM_MANAGER_LOGIN_FAIL = @"StreamManagerLoginFail";
static NSString *STREAM_MANAGER_LOGIN_SUCCESS = @"StreamManagerLoginSuccess";
static NSString *STREAM_MANAGER_CONNECT_FAIL = @"StreamManagerConnectFail";
static NSString *STREAM_MANAGER_CONNECT_SUCCESS = @"StreamManagerConnectSuccess";
static NSString *STREAM_MANAGER_REGISTER_FAIL = @"StreamManagerRegisterFail";
static NSString *STREAM_MANAGER_REGISTER_SUCCESS =  @"StreamManagerRegisterSuccess";
static NSString *STREAM_MANAGER_RECEIVE_SUBSCRIBE = @"StreamManagerReceiveSubscribe";

static NSString *MESSAGE_TYPE = @"MessageType";
static NSString *VOICE = @"VoiceMessage";
static NSString *TEXT = @"TextMessage";
static NSString *IMG = @"ImageMessage";

static NSString *DEFAULT_AVARTAR = @"login_avatar_default";

static NSInteger MAX_LEN = 1024*1024;
static NSInteger MAX_VOICE_TIME = 6;

@interface GQStatic : NSObject 
+ (GQAppDelegate *)appDelegate;
+ (XMPPStream *)xmppStream;
+ (void)clearUserDeaults;
+ (NSString *)getCurrentTime;
@end
