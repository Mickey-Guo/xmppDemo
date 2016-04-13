//
//  GQChatDelegate.h
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol GQChatDelegate

- (void)newFriendOnline:(NSString *)friendName;
- (void)friendWentOffline:(NSString *)friendName;
- (void)didDisconnect;

@end

