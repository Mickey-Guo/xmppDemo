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
#import "GQStreamManager.h"
#import "GQRosterManager.h"

static NSString* FRIENDVIEW = @"FriendView";

@interface GQFriendsViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) NSMutableArray *onlineFriends;
@property (strong, nonatomic) NSString *chatUserName;

@property (strong, nonatomic) NSFetchedResultsController *friendsController;

- (void)showLogin;

@end

@implementation GQFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //GQAppDelegate *appDelegate = [GQStatic appDelegate];
    GQStreamManager *streamManager = [GQStreamManager manager];
    streamManager.chatDelegate = self;
    
    [self getFriends];
    
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


- (void)getFriends {
    NSLog(@"getting friends");
    _friendsController = [[GQRosterManager manager] getFriendsController];
    _friendsController.delegate = self;
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
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSString *s = (NSString *) [_onlineFriends objectAtIndex:indexPath.row];
//    
//    static NSString *CellIdentifier = @"FriendCell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    cell.textLabel.text = s;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    
//    return cell;
//    
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    
//    return [_onlineFriends count];
//    
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    
//    return 1;
//    
//}
//
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    _chatUserName= (NSString *) [_onlineFriends objectAtIndex:indexPath.row];
//    [self performSegueWithIdentifier:@"toChat" sender:self];
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"number of sections in table view, %ld", (long)[_friendsController sections].count);
    return [_friendsController sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionObj = [[_friendsController sections]
                                                  objectAtIndex:section];
    return [sectionObj numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FriendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    XMPPUserCoreDataStorageObject *friend = [_friendsController objectAtIndexPath:indexPath];
    cell.textLabel.text = friend.jidStr;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return (UITableViewCell *)cell;

}

#pragma mark -NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [_tView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [_tView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [_tView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [_tView endUpdates];
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
