//
//  GQRecentViewController.m
//  XmppDemo
//
//  Created by guoqing on 16/5/9.
//  Copyright © 2016年 guoqing. All rights reserved.
//

#import "GQRecentViewController.h"
#import "Recent+CoreDataProperties.h"
#import "GQXMPPRecent.h"
#import "GQChatViewController.h"
#import "GQStatic.h"
#import "GQRecentCell.h"
#import "GQMessageManager.h"
#import "NSFileManager+Tools.h"

@interface GQRecentViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tView;
@property (strong, nonatomic) GQXMPPRecent *recent;
@property (strong, nonatomic) NSFetchedResultsController *results;
@property (strong, nonatomic) NSString *friendName;
@end


@implementation GQRecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.recent = [GQXMPPRecent shareInstance];
    self.tView.dataSource = self;
    self.tView.delegate = self;
    self.tView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_bg2"]];
    NSLog(@"results: %@", self.results);
    self.navigationItem.leftBarButtonItem =self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    NSString *login = [[NSUserDefaults standardUserDefaults]objectForKey:USERID];
    if (login) {
        self.results = [self.recent getRecentFriends];
        self.results.delegate = self;
    } else {
        [self showLogin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLogin {
    [self performSegueWithIdentifier:@"toLogin" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (![segue.identifier isEqualToString:@"toChat"]) {
        return;
    }
    NSString *name = (NSString *)sender;
    GQChatViewController *dest = [segue destinationViewController];
    dest.friendName  = name;
    NSLog(@"Recent friendName:%@", self.friendName);
}

#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionObj = [[self.results sections]objectAtIndex:section];
    return [sectionObj numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.results.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"recentCell";
    GQRecentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    Recent *friend = [self.results objectAtIndexPath:indexPath];
    [cell setName:friend.name lastMessage:friend.lastMessage andLastTime:friend.lastTime];
    return cell;
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
    return @"Delete Messages";
}

//完成编辑后的操作
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Recent *friend = [self.results objectAtIndexPath:indexPath];
    [[GQMessageManager manager]deleteHistoryByName:friend.name];
    [NSFileManager deleteDirInCachPathWithName:friend.name];
    [self.recent removeRecentByName:friend.name];
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Recent *friend = [self.results objectAtIndexPath:indexPath];
    self.friendName = friend.name;
    [self performSegueWithIdentifier:@"toChat" sender:friend.name];
}

#pragma mark - FetchResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tView insertRowsAtIndexPaths:[NSArray arrayWithObject: newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tView endUpdates];
}

@end
