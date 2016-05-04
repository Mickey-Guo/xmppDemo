//
//  VoiceTableViewCell.h
//  chat
//
//  Created by yinxiufeng on 15/5/25.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@class mMessageFrame;

@interface VoiceTableViewCell : UITableViewCell

//本人头像
@property(nonatomic,strong)UIImage *sendPortraitImage;
//对方头像
@property(nonatomic,strong)UIImage *recivePortraitImage;

@property(nonatomic,strong) mMessageFrame *messageFrame;

@end
