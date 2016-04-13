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

@class GQFriendsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) IBOutlet UIWindow *window;
//@property (strong, nonatomic) IBOutlet GQFriendsViewController *viewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GQFriendsViewController *viewController;
@property (strong, readonly) XMPPStream *xmppStream;
@property (nonatomic) BOOL isOpen;
@property (strong, nonatomic) NSString *password;

@property (nonatomic) id chatDelegate;
@property (nonatomic) id messageDelegate;

- (BOOL)connetct;
- (void)disconnect;
@end

