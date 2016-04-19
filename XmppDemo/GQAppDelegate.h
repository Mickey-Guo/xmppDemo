//
//  AppDelegate.h
//  XmppDemo
//
//  Created by guoqing on 16/3/31.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"
#import "GQChatDelegate.h"
#import "GQMessageDelegate.h"
#import "GQLoginDelegate.h"
@class GQStreamManager;
@class GQRosterManager;
@class XMPPRoster;

@class GQFriendsViewController;

@interface GQAppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GQFriendsViewController *viewController;
@property (strong, readonly) XMPPStream *xmppStream;
@property (strong, nonatomic, readonly) XMPPRoster *roster;
@property (nonatomic) BOOL isOpen;
@property (strong, nonatomic) NSString *password;

@property (strong, nonatomic, readonly) GQStreamManager *streamManager;
@property (strong, nonatomic, readonly) GQRosterManager *rosterManager;

@end

