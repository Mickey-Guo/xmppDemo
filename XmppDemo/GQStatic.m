//
//  GQStatic.m
//  XmppDemo
//
//  Created by guoqing on 16/4/14.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQStatic.h"

@interface GQStatic()

@end

@implementation GQStatic
+ (GQAppDelegate *)appDelegate{
    return (GQAppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

+ (void)clearUserDeaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // $$$$$
    
    [defaults removeObjectForKey:USERID];
    [defaults removeObjectForKey:PASS];
    [defaults removeObjectForKey:SERVER];
    
    // 刚存完偏好设置，必须同步一下
    [defaults synchronize];
    NSLog(@"DELETE USERDEFAULTS");
}
@end
