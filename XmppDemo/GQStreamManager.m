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

typedef NS_ENUM(NSInteger, ManagerOpertion) {
    ManagerOpertionLogin,
    ManagerOpertionRegister
};

@interface GQStreamManager() <XMPPStreamDelegate>

@property (strong, nonatomic) XMPPStream *stream;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *resource;

@property (assign, nonatomic) ManagerOpertion operation;
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


- (void)login {
    self.operation = ManagerOpertionLogin;
    [self connect];
    return;
    //[_stream disconnect];
    
    [self getStream];
    [self getUser];
    NSLog(@"name:%@ pass:%@ server:%@ resource:%@",_name, _password, _server, _resource);
    
    XMPPJID *jid = [XMPPJID jidWithUser:_name domain:_server resource:_resource];
    NSLog(@"XMPPJID *jid = %@",jid);
    [self getConnectWithJID:jid];
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
    NSLog(@"setMyJID:%@", _stream.myJID);
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
    switch (self.operation) {
        case ManagerOpertionLogin:
            if (![self.stream authenticateWithPassword:self.password error:&error]) {
                NSLog(@"AUTHENTICATE ERROR:%@", error);
            }
            break;
        case ManagerOpertionRegister:
            if (![self.stream registerWithPassword:self.password error:&error]) {
                NSLog(@"REGISTERWITHPASSWORD ERROR:%@",error);
            }
            break;
        default:
            break;
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
        } else if ([presenceType isEqualToString:@"unavailable"]) {
        }
    }
    
}

//the delegate will use these events to populate the online buddies table accordingly.
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"Message:%@", message);
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Register Success"
                                          message:@"tap Back to login"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *backAction = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     
                                 }];
    [alertController addAction:backAction];
}

- (void)registerWithName:(NSString *)name Password:(NSString *)password ServerAddress:(NSString *)serverAddress {
    self.operation = ManagerOpertionRegister;
    self.password = password;
    [self getStream];
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:serverAddress resource:@"iPhone"];
    
    [self getConnectWithJID:jid];
}

- (void)getConnectWithJID:(XMPPJID *)jid {
    _stream.myJID = jid;
    NSLog(@"_stream.myJID:%@", _stream.myJID);
    NSError *err = nil;
    if (![_stream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
        NSLog(@"connect error: %@", err);
    }
}

- (void) getUser {
    //NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:USERID];
    self.name = [[NSUserDefaults standardUserDefaults] stringForKey:USERID];
    self.password = [[NSUserDefaults standardUserDefaults] stringForKey:PASS];
    self.server = [[NSUserDefaults standardUserDefaults] stringForKey:SERVER];
    self.resource = [[NSUserDefaults standardUserDefaults] stringForKey:SOURCE];
}

@end
