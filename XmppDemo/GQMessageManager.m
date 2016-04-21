//
//  GQMessageManager.m
//  XmppDemo
//
//  Created by guoqing on 16/4/21.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQMessageManager.h"
#import "GQAppDelegate.h"
#import "GQStatic.h"

@interface GQMessageManager()

@property (strong, nonatomic) XMPPMessageArchiving *archiving;

@end

@implementation GQMessageManager

+ (instancetype)manager {
    return [GQStatic appDelegate].messageManager;
}

- (void)getMessageArchiving {
    _archiving = [GQStatic appDelegate].messageArchiving;
}

- (NSFetchedResultsController *)getHistoryByName:(NSString *)name {
    NSManagedObjectContext *context = [[XMPPMessageArchivingCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    NSFetchRequest *request = [NSFetchRequest
                               fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"bareJidStr=%@", name];
    request.predicate = predicate;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc]
                                                     initWithFetchRequest:request
                                                     managedObjectContext:context
                                                     sectionNameKeyPath:nil
                                                     cacheName:nil];
    
    NSError *error = nil;
    [resultsController performFetch:&error];
    if (error) {
        NSLog(@"Fetch message for %@ failed: %@", name, error);
    }
    
    return resultsController;
}

- (void)sendMessage:(NSString *)body forUser:(XMPPJID *)jid {
    if (body.length < 1) {
        return;
    }
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    [message addBody:body];
    
    [[GQStatic appDelegate].xmppStream sendElement:message];
}

- (void)deleteMessageStorage {
    XMPPMessageArchivingCoreDataStorage *storage = _archiving.xmppMessageArchivingStorage;
    NSError *error = nil;
    [[NSFileManager defaultManager]removeItemAtPath:storage.databaseFileName error:&error];
    if (error) {
        NSLog(@"delete message storage failed: %@", error);
    } else {
        NSLog(@"delete message storage success");
    }
}

@end
