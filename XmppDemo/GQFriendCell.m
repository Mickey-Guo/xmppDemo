//
//  GQFriendCell.m
//  XmppDemo
//
//  Created by guoqing on 16/4/20.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQFriendCell.h"

@interface GQFriendCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *presenceLabel;

@end

@implementation GQFriendCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)n {
    if (![n isEqualToString:_name]) {
        _name = [n copy];
        self.nameLabel.text = _name;
    }
}

- (void)setPresence:(NSString *)p {
    if (![p isEqualToString:_presence]) {
        _presence = [p copy];
        self.presenceLabel.text = _presence;
        if (![_presence isEqualToString:@"Online"]) {
            self.presenceLabel.textColor = [UIColor grayColor];
        } else {
            self.presenceLabel.textColor = self.tintColor;
        }
    }
}

@end
