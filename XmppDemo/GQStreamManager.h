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
#import "GQLoginDelegate.h"

@interface GQStreamManager : NSObject

@property (nonatomic) id<GQMessageDelegate> messageDelegate;
@property (nonatomic) id<GQLoginDelegate> loginDelegate;

+ (GQStreamManager *) manager;

- (void)login;
- (BOOL)connect;
- (void)disconnect;
- (void)registerWithName: (NSString *)name Password:(NSString *)password ServerAddress:(NSString *)serverAddress;

@end
