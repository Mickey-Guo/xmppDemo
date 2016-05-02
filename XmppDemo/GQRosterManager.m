//
//  GQRosterManager.m
//  XmppDemo
//
//  Created by guoqing on 16/4/19.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQRosterManager.h"
#import "GQStreamManager.h"
#import "GQAppDelegate.h"
#import "GQStatic.h"

@interface GQRosterManager()

@property (strong, nonatomic) XMPPRoster *roster;

@end

@implementation GQRosterManager

+ (GQRosterManager *)manager {
    GQAppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    return delegate.rosterManager;
}

- (id)init {
    self = [super init];
    [self getRoster];
    return self;
}

- (void)getRoster {
    GQAppDelegate *appDelegate = [GQStatic appDelegate];
    _roster = appDelegate.roster;
}

- (NSFetchedResultsController *)getFriendsController {
    NSManagedObjectContext *context = [[XMPPRosterCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //排序
    NSSortDescriptor * sort1 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];//jidStr
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
    
    request.sortDescriptors = @[sort2, sort1];
    
    NSFetchedResultsController *fetchFriends = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![fetchFriends performFetch:&error]) {
        NSLog(@"fetching friends error: %@", error);
    }
    
    //返回的数组是XMPPUserCoreDataStorageObject  *obj类型的
    //名称为 obj.displayName
    return fetchFriends;
}

- (void)acceptFriend:(XMPPJID *)jid {
    [_roster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}

- (void)rejectFriend:(XMPPJID *)jid {
    [_roster rejectPresenceSubscriptionRequestFrom:jid];
}

- (void)addFriend:(NSString *)name {
    XMPPJID *friendJID = [XMPPJID jidWithString:name];
    [_roster addUser:friendJID withNickname:nil];
}

- (void)removeFriend:(NSString *)name {
    XMPPJID *friendJID = [XMPPJID jidWithString:name];
    [_roster removeUser:friendJID];
    NSLog(@"removed friend %@", name);
}

- (XMPPUserCoreDataStorageObject *)getUserByName:(NSString *)name {
    XMPPRosterCoreDataStorage *storage = [XMPPRosterCoreDataStorage sharedInstance];
    XMPPUserCoreDataStorageObject *user = [storage userForJID:[XMPPJID jidWithString:name] xmppStream:_roster.xmppStream managedObjectContext:[storage mainThreadManagedObjectContext]];
    
    return user;
}

- (void)deleteRosterStorage {
    XMPPRosterCoreDataStorage *storage = _roster.xmppRosterStorage;
    NSError *err = nil;
    [[NSFileManager defaultManager]removeItemAtPath:storage.databaseFileName error:&err];
    if (err) {
        NSLog(@"delete roster failed: %@", err);
    }else {
        NSLog(@"delete roster success");
    }
}
@end
