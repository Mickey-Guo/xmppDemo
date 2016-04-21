//
//  GQStreamManager.m
//  XmppDemo
//
//  Created by guoqing on 16/4/19.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQStreamManager.h"
#import "GQAppDelegate.h"
#import "GQStatic.h"
#import "GQLoginDelegate.h"
#import "GQMessageDelegate.h"

@interface GQStreamManager() <XMPPStreamDelegate>

@property (strong, nonatomic) XMPPStream *stream;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *resource;

@property (strong, nonatomic) GQAppDelegate *appDelegate;

@end

@implementation GQStreamManager

#pragma mark- class methods
+ (GQStreamManager *)manager {
    GQAppDelegate *appDelegate = [GQStatic appDelegate];
    return appDelegate.streamManager;
}

#pragma mark- public methods
- (id)init {
    if (self = [super init]) {
        _appDelegate = [GQStatic appDelegate];
        [self getStream];
    }
    
    return self;
}

- (void)getStream {
    _stream = _appDelegate.xmppStream;
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [_stream sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_stream sendElement:presence];
}

- (BOOL)connect {
    
    //[self setupStream];
    NSLog(@"Start to connect");
    
    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:USERID];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:PASS];
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:SERVER];
    
    if (![_stream isDisconnected]) {
        NSLog(@"connected!");
        return YES;
    }
    
    if (jabberID == nil || myPassword == nil) {
        NSLog(@"jabberID and myPassword may be nil");
        return NO;
    }
    
    NSLog(@"id:%@ password:%@ server:%@", jabberID, myPassword, server);
    //set UserId
    [_stream setMyJID:[XMPPJID jidWithString:jabberID]];
    //set Password
    _password = myPassword;
    //set ServerAddress
    [_stream setHostName:server];
    
    
    NSError *error = nil;
    if (![_stream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        NSLog(@"CONNECT ERROR");
        return NO;
    }
    return YES;
}

- (void)disconnect {
    
    [self goOffline];
    [_stream disconnect];
    NSLog(@"XmppStream disconnet");
    
}

#pragma mark- XMPPStream delegates
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidConnect");
    //_isOpen = YES;
    NSError *error = nil;
    if (![self.stream authenticateWithPassword:_password error:&error]) {
        NSLog(@"AUTHENTICATE ERROR:%@", error);
    }
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"XmppStreamConnectDidTimeout");
    [self.loginDelegate didNotConnect];
}

//when authentication is successful, we should notify the server that we are online
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidAuthenticate");
    [self goOnline];
    [self.loginDelegate didAuthenticate];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"AUTHENTICATE FAILED:%@", error);
    [self.loginDelegate didNotAuthenticate];
}

//when we receive a presence notification, we can dispatch the message to the chat delegate
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSLog(@"presence : %@, %@", presence.fromStr, presence.type);
    
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername]) {
        if ([presenceType isEqualToString:@"available"]) {
//            [_chatDelegate newFriendOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, HOSTNAME]];
        } else if ([presenceType isEqualToString:@"unavailable"]) {
//            [_chatDelegate friendWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, HOSTNAME]];
        }
    }
    
}

//the delegate will use these events to populate the online buddies table accordingly.
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"Message:%@", message);
    /*if (![message isChatMessageWithBody]) {
        return;
    }
    NSString *body = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *time = [GQStatic getCurrentTime];
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:body forKey:@"msg"];
    [m setObject:from forKey:@"sender"];
    [m setObject:time forKey:@"time"];
    NSLog(@"time: %@", time);
    
    [_messageDelegate newMessageReceived:m];*/
}

@end
