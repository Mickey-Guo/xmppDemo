//
//  GQMeViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/4/14.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQMeViewController.h"
#import "GQAppDelegate.h"
#import "GQStatic.h"
#import "GQStreamManager.h"
#import "GQRosterManager.h"

@interface GQMeViewController()

@property (weak, nonatomic) IBOutlet UILabel *idLabel;
- (IBAction)logout:(id)sender;
@end

@implementation GQMeViewController

- (void)viewDidAppear:(BOOL)animated {
    NSString *name = [[NSUserDefaults standardUserDefaults]objectForKey:USERID];
    NSString *server = [[NSUserDefaults standardUserDefaults]objectForKey:SERVER];
    NSString *labelText = [NSString stringWithFormat:@"%@@%@", name, server];
    self.idLabel.text = [labelText copy];
    self.navigationItem.title = @"Me";
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"friend_bg2"]]];
}

- (IBAction)logout:(id)sender {
    [GQStatic clearUserDeaults];
    [self.tabBarController setSelectedIndex:0];
    GQStreamManager *streamManager = [GQStreamManager manager];
    [streamManager disconnect];
    [[GQRosterManager manager] deleteRosterStorage];
}
@end
