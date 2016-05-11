//
//  GQXMPPRecent.m
//  XmppDemo
//
//  Created by guoqing on 16/5/9.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQXMPPRecent.h"
#import "Recent+CoreDataProperties.h"
#import "GQStatic.h"
#import "GQStreamManager.h"

@interface GQXMPPRecent()

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSURL *persistentStoreURL;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation GQXMPPRecent

+ (instancetype)shareInstance {
    static GQXMPPRecent *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GQXMPPRecent alloc]init];
    });
    return instance;
}

- (void)setUp {
    self.context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    self.context.persistentStoreCoordinator = [self persistentStoreCoordinator];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
//    if (_persistentStoreCoordinator) {
//        return _persistentStoreCoordinator;
//    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    NSString *jidString = [GQStatic appDelegate].xmppStream.myJID.bare;
    NSString *appendURL = [NSString stringWithFormat:@"%@.Recent.sqlite", jidString];
    NSURL *storeURL = [[self applicationDocumentsDirectory]
                       URLByAppendingPathComponent:appendURL];
    NSError *error = nil;
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:storeURL
                                                    options:nil
                                                      error:nil];
    if (!store) {
        NSLog(@"NSPersistentStore error: %@",error);
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    NSURL *modelURL = [[NSBundle mainBundle]
                       URLForResource:@"Recent" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc]
                           initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSURL*)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentationDirectory                               inDomains:NSUserDomainMask]lastObject];
}
- (void)insertName:(NSString *)name message:(NSString *)message time:(NSDate *)date {
    Recent *friend = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Recent"];
    request.predicate = [NSPredicate predicateWithFormat:@"name contains %@", name];
    NSArray *arr = [_context executeFetchRequest:request error:nil];
    if (arr.count <= 0) {
        friend = [NSEntityDescription insertNewObjectForEntityForName:@"Recent" inManagedObjectContext:_context];
        friend.name = name;
        
    }else {
        friend = [arr firstObject];
    }
    friend.lastMessage = message;
    friend.lastTime = date;
    NSError *err = nil;
    if(![_context save:&err]) {
        NSLog(@"save failed");
    }
}

- (NSFetchedResultsController *)getRecentFriends {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Recent"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastTime" ascending:NO];
    request.sortDescriptors = @[sort];
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil];
    
    NSError *err = nil;
    [resultsController performFetch:&err];
    if (err) {
        NSLog(@"err");
    }
    
    return resultsController;
}

- (void)removeRecentByName:(NSString *)name {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Recent" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.entity = entityDescription;
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"name=%@", name];
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *recentList = [self.context executeFetchRequest:request error:&error];
    if ([recentList count] > 0) {
        int count = (int)[recentList count];
        for (int i = 0; i < count; i++) {
            NSManagedObject *message = [recentList objectAtIndex:i];
            [self.context deleteObject:message];
            error  = nil;
            if ([self.context hasChanges] && ![self.context save:&error]) {
                NSLog(@"删除和%@的recent记录失败", name);
            }
        }
    }

}

- (void)deleteRecentStorage {
    NSError *err = nil;
    [[NSFileManager defaultManager]removeItemAtPath:[_persistentStoreURL path] error:&err];
    if (err) {
        NSLog(@"delete recent failed: %@", err);
    }else {
        NSLog(@"delete recent success");
    }
}

@end
