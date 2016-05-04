//
//  ChatTableViewCell.h
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class mMessageFrame;

@interface TextTableViewCell : UITableViewCell

//本人头像
@property(nonatomic,strong)UIImage *sendPortraitImage;
//对方头像
@property(nonatomic,strong)UIImage *recivePortraitImage;

@property(nonatomic,strong) mMessageFrame *messageFrame;

@end
