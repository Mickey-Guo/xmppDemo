//
//  GQFriendsViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/4/12.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQFriendsViewController.h"
#import "GQChatViewController.h"
#import "GQStatic.h"

static NSString* FRIENDVIEW = @"FriendView";

@interface GQFriendsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) NSMutableArray *onlineFriends;
@property (strong, nonatomic) NSString *chatUserName;

- (void)showLogin;

@end

@implementation GQFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GQAppDelegate *del = [GQStatic appDelegate];
    del.chatDelegate = self;
    self.tView.delegate = self;
    self.tView.dataSource = self;
    _onlineFriends = [[NSMutableArray alloc] init];
    NSLog(@"%@ did load", FRIENDVIEW);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *login = [[NSUserDefaults standardUserDefaults]objectForKey:USERID];
    if (login) {
//        if ([[GQStatic appDelegate] connect]) {
//            NSLog(@"Show buddy list");
//        }
    } else {
        [_onlineFriends removeAllObjects];
        [self.tView reloadData];
        [self showLogin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toChat"]) {
        GQChatViewController *chatController = segue.destinationViewController;
        chatController.chatWithUser = _chatUserName;
    }
}


- (void)showLogin {
    //GQLoginViewController *loginController = [[GQLoginViewController alloc] init];
    //[self presentModalViewController:loginController animated:YES];
    [self performSegueWithIdentifier:@"toLogin" sender:self];
}
    
#pragma mark -
#pragma mark Table view delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *s = (NSString *) [_onlineFriends objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"FriendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = s;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_onlineFriends count];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _chatUserName= (NSString *) [_onlineFriends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toChat" sender:self];
    
}

-(XMPPStream *)xmppStream {
    return [[GQStatic appDelegate] xmppStream];
}

- (void)newFriendOnline:(NSString *)friendName {
    if ([_onlineFriends indexOfObject:friendName] != NSNotFound) {
        return ;
    }
    [_onlineFriends addObject:friendName];
    [self.tView reloadData];
}

- (void)friendWentOffline:(NSString *)friendName {
    [_onlineFriends removeObject: friendName];
    [self.tView reloadData];
}

-(void)didDisconnect {
    [_onlineFriends removeAllObjects];
    [self.tView reloadData];
}

@end
