//
//  GQMessageCell.h
//  XmppDemo
//
//  Created by guoqing on 16/4/15.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GQMessageCell : UITableViewCell

@property (nonatomic, strong) UILabel *senderAndTimeLabel;
@property (nonatomic, strong) UITextView *messageContentView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSString *audioPath;

@end
