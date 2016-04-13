//
//  GQFriendsViewController.h
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQChatDelegate.h"
#import "AppDelegate.h"

@interface GQFriendsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, GQChatDelegate>

@end
