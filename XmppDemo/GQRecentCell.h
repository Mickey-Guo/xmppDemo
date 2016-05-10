//
//  GQRecentCell.h
//  XmppDemo
//
//  Created by guoqing on 16/5/10.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GQRecentCell : UITableViewCell



- (void)setName:(NSString *)name lastMessage:(NSString *)lastMessage andLastTime:(NSDate *)lastTime;
@end
