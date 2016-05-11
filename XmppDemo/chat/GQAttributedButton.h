//
//  GQAttributedButton.h
//  XmppDemo
//
//  Created by guoqing on 16/5/11.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface GQAttributedButton : UIButton

@property(nullable, nonatomic,readonly,strong) TTTAttributedLabel     *messageLabel NS_AVAILABLE_IOS(3_0);

@end
