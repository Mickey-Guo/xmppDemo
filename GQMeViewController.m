//
//  GQMeViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/4/14.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQMeViewController.h"
#import "AppDelegate.h"
#import "GQStatic.h"

@interface GQMeViewController()

- (IBAction)logout:(id)sender;
@end

@implementation GQMeViewController

- (IBAction)logout:(id)sender {
    [GQStatic clearUserDeaults];
    [self.tabBarController setSelectedIndex:0];
    AppDelegate *del = [GQStatic appDelegate];
    [del disconnect];
}
@end
