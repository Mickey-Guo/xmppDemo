//
//  AppDelegate.m
//  XmppDemo
//
//  Created by guoqing on 16/3/31.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQAppDelegate.h"
#import "GQStatic.h"
#import "GQStreamManager.h"
#import "GQRosterManager.h"


@interface GQAppDelegate ()

@end

@implementation GQAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    _xmppStream = [[XMPPStream alloc] init];
    _streamManager = [[GQStreamManager alloc] init];
    [_xmppStream addDelegate:_streamManager delegateQueue:dispatch_get_main_queue()];
    NSLog(@"applicationDidFinishLaunching");
    [_streamManager connect];
    
    
    //注册花名册
    XMPPRosterCoreDataStorage *rosterDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
    _roster = [[XMPPRoster alloc]initWithRosterStorage:rosterDataStorage];
    _roster.autoFetchRoster = YES;
    [_roster activate:_xmppStream];
    _rosterManager = [[GQRosterManager alloc]init];
    [_roster addDelegate:_rosterManager delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
