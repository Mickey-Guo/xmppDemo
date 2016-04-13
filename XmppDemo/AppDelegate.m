//
//  AppDelegate.m
//  XmppDemo
//
//  Created by guoqing on 16/3/31.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

- (void)setupStream;
- (void)goOnline;
- (void)goOffline;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self connect];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupStream {
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

- (BOOL)connect {
    
    [self setupStream];
    
    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"];
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverAddress"];
    
    if (![_xmppStream isDisconnected]) {
        NSLog(@"connected!");
        return YES;
    }
    
    if (jabberID == nil || myPassword == nil) {
        NSLog(@"jabberID and myPassword may be nil");
        return NO;
    }
    
    //set UserId
    [_xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    //set Password
    _password = myPassword;
    //set ServerAddress
    [_xmppStream setHostName:server];
    
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        NSLog(@"connect failed");
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect {
    
    [self goOffline];
    [_xmppStream disconnect];
    
}

#pragma mark -
#pragma XMPP delegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    _isOpen = YES;
    NSError *error = nil;
    [self.xmppStream authenticateWithPassword:_password error:&error];
}

//when authentication is successful, we should notify the server that we are online
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self goOnline];
}

//when we receive a presence notification, we can dispatch the message to the chat delegate
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername]) {
        if ([presenceType isEqualToString:@"available"]) {
            [_chatDelegate newFriendOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            [_chatDelegate friendWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
        }
    }
    
}

//the delegate will use these events to populate the online buddies table accordingly.
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:msg forKey:@"msg"];
    [m setObject:from forKey:@"sender"];
    
    [_messageDelegate newMessageReceived:m];
}
@end
