//
//  GQMessageCell.m
//  XmppDemo
//
//  Created by guoqing on 16/4/15.
//  Copyright © 2016年 guoqing. All rights reserved.
//
#import "GQMessageCell.h"

@implementation GQMessageCell

@synthesize senderAndTimeLabel;
@synthesize messageContentView;
@synthesize bgImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //日期标签
        CGRect rx = [UIScreen mainScreen].bounds;
        senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, rx.size.width-20, 20)];
        //居中显示
        senderAndTimeLabel.textAlignment = NSTextAlignmentCenter;
        senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        //文字颜色
        senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:senderAndTimeLabel];
        
        //背景图
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bgImageView];
        
        //聊天信息
        messageContentView = [[UITextView alloc] init];
        messageContentView.backgroundColor = [UIColor clearColor];
        //不可编辑
        messageContentView.editable = NO;
        messageContentView.scrollEnabled = NO;
        [messageContentView sizeToFit];
        [self.contentView addSubview:messageContentView];
    }
    return self;
}

@end
