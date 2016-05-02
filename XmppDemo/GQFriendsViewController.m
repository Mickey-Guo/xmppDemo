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
#import "GQFriendCell.h"
#import "GQStreamManager.h"
#import "GQRosterManager.h"
#import "GQMessageManager.h"


static NSString* FRIENDVIEW = @"FriendView";

@interface GQFriendsViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) NSString *chatUserName;

@property (strong, nonatomic) NSFetchedResultsController *friendsController;

- (void)showLogin;

@end

@implementation GQFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getFriends];
    
    self.tView.delegate = self;
    self.tView.dataSource = self;
    self.navigationItem.leftBarButtonItem =self.editButtonItem;
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
        chatController.friendName = _chatUserName;
    }
}


- (void)showLogin {
    [self performSegueWithIdentifier:@"toLogin" sender:self];
}
    
#pragma mark -
#pragma mark Table view delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    XMPPUserCoreDataStorageObject *friend = [_friendsController objectAtIndexPath:indexPath];
    _chatUserName = friend.jidStr;
    
    [self performSegueWithIdentifier:@"toChat" sender:self];
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
    static NSString *CellIdentifier = @"GQFriendCell";
    
    GQFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = (GQFriendCell *)[[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil].firstObject;
        [_tView registerNib:[UINib nibWithNibName:CellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
        cell = [_tView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    XMPPUserCoreDataStorageObject *friend = [_friendsController objectAtIndexPath:indexPath];
    cell.name = friend.jidStr;
    switch (friend.section) {
        case 0:
            cell.presence = @"Online";
            break;
        case 1:
            cell.presence = @"Leaving";
            break;
        case 2:
            cell.presence = @"Offline";
            break;
        default:
            cell.presence = @"Unknown";
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return (UITableViewCell *)cell;
}

//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:YES animated:YES];
    return UITableViewCellEditingStyleDelete;
}

//设置编辑模式显示样式
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete Friend";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *friend = [_friendsController objectAtIndexPath:indexPath];
    [[GQMessageManager manager]deleteHistoryByName:friend.jidStr];
    [[GQRosterManager manager]removeFriend:friend.jidStr];
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

@end
