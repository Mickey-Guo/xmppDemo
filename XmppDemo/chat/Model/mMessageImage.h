//
//  mMessageImage.h
//  chat
//
//  Created by yinxiufeng on 15/5/23.
//  Copyright (c) 2015年 yinxiufeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mMessageImage : NSObject

//图片服务器地址
@property(nonatomic,strong) NSString *imageUrl;
//图片宽度
@property(nonatomic,assign) float width;
//图片高度
@property(nonatomic,assign) float height;

-(instancetype)initDictionary:(NSDictionary *)dictionary;


@end
