//
//  GQXMPPRecent.h
//  XmppDemo
//
//  Created by guoqing on 16/5/9.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface GQXMPPRecent : NSObject

@property (strong, nonatomic) UIManagedDocument *managedDocument;

+ (instancetype) shareInstance;

- (void)setUp;
- (void)insertName:(NSString *)name message:(NSString *)message time:(NSDate *)date;
- (NSFetchedResultsController *)getRecentFriends;

- (void)deleteRecentStorage;

@end
