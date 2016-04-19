//
//  GQStreamManager.h
//  XmppDemo
//
//  Created by guoqing on 16/4/19.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "GQMessageDelegate.h"
#import "GQChatDelegate.h"
#import "GQLoginDelegate.h"

@interface GQStreamManager : NSObject

@property (nonatomic) id<GQChatDelegate> chatDelegate;
@property (nonatomic) id<GQMessageDelegate> messageDelegate;
@property (nonatomic) id<GQLoginDelegate> loginDelegate;

+ (GQStreamManager *) manager;

- (BOOL)connect;
- (void)disconnect;

@end
