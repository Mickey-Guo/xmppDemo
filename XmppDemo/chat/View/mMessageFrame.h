//
//  mMessageFrame.h
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class mMessage;

@interface mMessageFrame : NSObject

//时间frame
@property(nonatomic,assign)CGRect dateTimeFrame;
//用户头像frame
@property(nonatomic,assign)CGRect portraitFrame;
//内容frame
@property(nonatomic,assign)CGRect contentFrame;

//cell高度
@property(nonatomic,assign)CGFloat cellHeight;

@property(nonatomic,strong)mMessage *messageModel;


@end
