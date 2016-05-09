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

- (void)deleteHistoryByName:(NSString *)name {
    NSManagedObjectContext *context = [[XMPPMessageArchivingCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:description];
    
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"bareJidStr=%@", name];
    request.predicate = predicate;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    NSError *error = nil;
    NSArray *historyList = [context executeFetchRequest:request error:&error];
    if ([historyList count] > 0) {
        int count = (int)[historyList count];
        for (int i = 0; i < count; i++) {
            NSManagedObject *message = [historyList objectAtIndex:i];
            [context deleteObject:message];
            error  = nil;
            if ([context hasChanges] && ![context save:&error]) {
                NSLog(@"删除和%@的聊天记录失败", name);
            }
        }
    }
}

- (void)sendMessage:(NSString *)body toUser:(NSString *)friendName {
    if (body.length < 1) {
        return;
    }
    XMPPJID *jid = [XMPPJID jidWithString:friendName];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    [message addBody:body];
    XMPPElement *typeName = [XMPPElement elementWithName:MESSAGE_TYPE stringValue:TEXT];
    //DDXMLElement *element = [XMPPElement elementWithName:MESSAGE_TYPE numberValue:@1];
    [message addChild:typeName];
    //NSLog(@"Sent to: %@ Content: %@", jid, message);
    [[GQStatic appDelegate].xmppStream sendElement:message];
}

- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)body typeName:(NSString *)type toUser:(NSString *)friendName {
    XMPPJID *jid = [XMPPJID jidWithString:friendName];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    [message addBody:body];
    
    XMPPElement *typeName = [XMPPElement elementWithName:MESSAGE_TYPE stringValue:type];
    [message addChild:typeName];
    
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
    [message addChild:attachment];
    
    [[GQStatic appDelegate].xmppStream sendElement:message];

    NSLog(@"send data message:%@, to:%@", message.body, message.toStr);
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
