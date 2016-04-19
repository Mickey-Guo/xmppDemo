//
//  GQRosterManager.h
//  XmppDemo
//
//  Created by guoqing on 16/4/19.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPRoster.h"

@interface GQRosterManager : NSObject <NSFetchedResultsControllerDelegate>

+ (GQRosterManager *)manager;

- (NSFetchedResultsController *)getFriendsController;

- (void)acceptFriend:(XMPPJID *)jid;
- (void)rejectFriend:(XMPPJID *)jid;
- (void)addFriend:(XMPPJID *)jid;
- (void)removeFriend:(NSString *)name;

- (XMPPUserCoreDataStorageObject *)getUserByName:(NSString *)name;
- (void)deleteRosterStorage;
@end
