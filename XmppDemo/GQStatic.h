//
//  GQStatic.h
//  XmppDemo
//
//  Created by guoqing on 16/4/14.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQAppDelegate.h"

static NSString *USERID = @"userId";
static NSString *PASS= @"pass";
static NSString *SERVER = @"server";
static NSString *HOSTNAME = @"xmpp.test";

static NSString *PASSWORD_ERROR = @"Your password is wrong. Please input again.";
static NSString *CONNECT_FAILED = @"Failed to connect the server. Please try again.";
static NSString *OK = @"OK";
static NSString *WARNING = @"Warining";
static float padding = 20;

@interface GQStatic : NSObject 
+ (GQAppDelegate *)appDelegate;
+ (XMPPStream *)xmppStream;
+ (void)clearUserDeaults;
@end
