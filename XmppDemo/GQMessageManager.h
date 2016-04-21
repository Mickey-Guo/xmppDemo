//
//  GQMessageManager.h
//  XmppDemo
//
//  Created by guoqing on 16/4/21.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

@interface GQMessageManager : NSObject

+ (instancetype)manager;

- (NSFetchedResultsController *)getHistoryByName:(NSString *)name;
- (void)sendMessage:(NSString *)body forUser:(XMPPJID *)jid;
- (void)deleteMessageStorage;
@end
