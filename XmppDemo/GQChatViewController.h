//
//  GQChatViewController.h
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GQChatViewController : UIViewController
@property (nonatomic, retain) NSString *friendName;

- (id) initWithUser: (NSString *) userName;
- (void)scrollToButtomWithAnimated:(BOOL)animated;
@end
