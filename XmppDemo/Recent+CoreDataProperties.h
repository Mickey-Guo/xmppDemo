//
//  Recent+CoreDataProperties.h
//  XmppDemo
//
//  Created by guoqing on 16/5/9.
//  Copyright © 2016年 guoqing. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Recent.h"

NS_ASSUME_NONNULL_BEGIN

@interface Recent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *lastMessage;
@property (nullable, nonatomic, retain) NSDate *lastTime;

@end

NS_ASSUME_NONNULL_END
