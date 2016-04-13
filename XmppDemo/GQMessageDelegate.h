//
//  GQMessageDelegate.h
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//
#import <UIkit/UIKit.h>

@protocol GQMessageDelegate

- (void)newMessageReceived:(NSDictionary *)messageContent;

@end