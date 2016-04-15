//
//  GQLoginDelegate.h
//  XmppDemo
//
//  Created by guoqing on 16/4/14.
//  Copyright © 2016年 guoqing. All rights reserved.
//
#import <UIkit/UIKit.h>

@protocol GQLoginDelegate

- (void)didAuthenticate;
- (void)didNotAuthenticate;
- (void)didNotConnect;

@end