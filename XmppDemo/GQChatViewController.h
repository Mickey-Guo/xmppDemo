//
//  GQChatViewController.h
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GQChatViewController : UIViewController
@property (nonatomic, retain) NSString *chatWithUser;

- (id) initWithUser: (NSString *) userName;
@end
