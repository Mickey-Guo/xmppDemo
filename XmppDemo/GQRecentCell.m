//
//  GQRecentCell.m
//  XmppDemo
//
//  Created by guoqing on 16/5/10.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQRecentCell.h"

@interface GQRecentCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeLabel;

@end

@implementation GQRecentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name lastMessage:(NSString *)lastMessage andLastTime:(NSDate *)lastTime {
    self.nameLabel.text = name;
    self.lastMessageLabel.text = lastMessage;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:lastTime];
    self.lastTimeLabel.text = dateStr;
}

@end
