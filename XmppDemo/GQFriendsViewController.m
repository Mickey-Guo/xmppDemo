//
//  GQFriendsViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQFriendsViewController.h"

@interface GQFriendsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) NSMutableArray *onlineFriends;

@end

@implementation GQFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *del = [self appDelegate];
    del.chatDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *login = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    if (login) {
        if ([[self appDelegate] connetct]) {
            NSLog(@"Show buddy list");
        }
    } else {
        [self showLogin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

-(XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

- (void)newFriendOnline:(NSString *)friendName {
    [onlineFriends addObject:friendName];
    [self.tView reloadData];
}

- (void)friendWentOffline:(NSString *)friendName {
    [onlineFriends removeObject: friendName];
    [self.tView reloadData];
}

@end
